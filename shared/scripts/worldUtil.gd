extends Node

var player: Player = Player.new()
var currentDialog: Dialog
var currentTrade: Trade
var current_prg: ProceduralRoomGenerator

func _enter_tree():
	add_child(player)

func createDialog(npc_id:String, dialog_data_path:String) -> Dialog:
	if !currentDialog:
		currentDialog = Dialog.new_instance(dialog_data_path, Callable(player.body, "setInDialog"))
		add_quest_dialogs(npc_id, currentDialog)
		currentDialog.load_dialog_data()
		add_child(currentDialog)
	return currentDialog

func add_quest_dialogs(npc_id, _currentDialog):
	for _quest in QuestLoader.get_quests():
		if _quest.status != Quest.Status.ACTIVE:
			continue
		var _task = _quest.get_active_task()
		if !_task:
			continue
		var additional_dialog = _task.dialog as TaskDialog
		if !additional_dialog or additional_dialog.npc != npc_id:
			continue
		_currentDialog.add_options(additional_dialog.source, additional_dialog.get_dialog_key(), additional_dialog.as_dialog_options())

func get_map_rng_visibility() -> bool:
	return current_prg.next_loot_visible()

# generic methods under this line #
###################################

func hasUnlocked(payload: Array):
	for key in payload:
		if !player.unlocks.has(key):
			return false
	return true

func openLastLoot(payload: Array):
	if currentTrade:
		return null
	player.store_inventory.moveItem(player.inventory, Inventory.GOLD_ITEM)
	var tradeInv = Inventory.from({
		Inventory.GOLD_ITEM: player.inventory.count(Inventory.GOLD_ITEM)
	})
	var taxList = Trader.get_taxes(FileUtil.getContentAsJson(payload[0]))
	currentTrade = Trade.new_instance(tradeInv, player.store_inventory,
		onLastLootAction, "Inventory", "Your saved loot", taxList)
	add_child(currentTrade)
	player.body.setInDialog(true)
	return currentTrade

func onLastLootAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		if not savePlayerTrade(payload[0]):
			return false
		player.store_inventory = Inventory.empty()
	player.body.setInDialog(false)
	currentTrade = null
	return true
	
func openShop(payload: Array):
	if currentTrade:
		return null
	var shopDetails = FileUtil.getContentAsJson(payload[0])
	var priceList = FileUtil.getContentAsJson(payload[1])
	var playerInv = Inventory.from({
		Inventory.GOLD_ITEM: player.inventory.count(Inventory.GOLD_ITEM)
	})
	var shopInv = Shop.create_shop_inventory(shopDetails["items"])
	currentTrade = Trade.new_instance(playerInv, shopInv,
		onShopAction, "Shopping cart", shopDetails["name"], priceList)
	add_child(currentTrade)
	player.body.setInDialog(true)
	return currentTrade
	
func onShopAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE and not savePlayerTrade(payload[0]):
		return false
	player.body.setInDialog(false)
	currentTrade = null
	return true
	
func savePlayerTrade(shoppingCart:Inventory):
	var newPlayerGold = shoppingCart.count(Inventory.GOLD_ITEM)
	if newPlayerGold < 0:
		return false
	shoppingCart.moveAllItems(player.inventory)
	player.inventory.set_total(Inventory.GOLD_ITEM, newPlayerGold)
	return true

func openSellLoot(payload: Array):
	if currentTrade:
		return null
	currentTrade = Trade.new_instance(player.inventory, Inventory.empty(),
		 onSellLootAction, "Inventory", "Your sell items",
		FileUtil.getContentAsJson(payload[0]))
	add_child(currentTrade)
	player.body.setInDialog(true)
	return currentTrade

func onSellLootAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		player.inventory = payload[0]
	player.body.setInDialog(false)
	currentTrade = null
	return true

func teleportToMissionMap(payload: Array):
	player.save()
	remove_child(current_prg)
	current_prg = ProceduralRoomGenerator.from_seed(str(payload[0]))
	add_child(current_prg)
	
func teleportToLowerShip(_payload: Array = []):
	player.teleport("ship", Vector3(-1,-3,-12))
	
func removeFromPlayerInventory(payload: Array = []) -> bool:
	var result = player.inventory.remove(payload[0], payload[1])
	WorldUtil.player.body.refresh_inventory_output()
	return result
	
func addToPlayerInventory(payload: Array):
	player.inventory.add(payload[0], payload[1])
	WorldUtil.player.body.refresh_inventory_output()
	
func checkPlayerInventory(payload: Array):
	return player.inventory.check(payload[0], payload[1])
	
func hasStoreInventoryItems(_payload: Array = []):
	return !player.store_inventory.is_empty()

func quitGame():
	save()
	get_tree().quit()

func save():
	player.save()
	
func respawn():
	player.run_inventory = Inventory.empty()
	teleportToLowerShip()
