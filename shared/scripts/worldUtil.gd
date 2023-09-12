extends Node

var player: Player = Player.new()
var currentDialog: Dialog
var currentTrade: Trade

func _enter_tree():
	add_child(player)

func createDialog(dialog_data_path:String) -> Dialog:
	if !currentDialog:
		currentDialog = Dialog.new_instance(dialog_data_path, Callable(player.body, "setInDialog"))
		add_child(currentDialog)
	return currentDialog

func openLastLoot(price_list_path:String):
	if currentTrade:
		return null
	player.store_inventory.moveItem(player.inventory, Inventory.GOLD_ITEM)
	var tradeInv = Inventory.from({
		Inventory.GOLD_ITEM: player.inventory.count(Inventory.GOLD_ITEM)
	})
	currentTrade = Trade.new_instance(tradeInv, player.store_inventory,
		onLastLootAction, "Inventory", "Your saved loot",
		FileUtil.getContentAsJson(price_list_path))
	add_child(currentTrade)
	player.body.setInDialog(true)
	return currentTrade

func onLastLootAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		var inv = payload[0] as Inventory
		var newPlayerGold = inv.count(Inventory.GOLD_ITEM)
		if newPlayerGold < 0:
			return false
		inv.moveAllItems(player.inventory)
		player.inventory.set_total(Inventory.GOLD_ITEM, newPlayerGold)
		player.store_inventory = Inventory.empty()
	player.body.setInDialog(false)
	currentTrade = null
	return true

func openSellLoot(price_list_path:String):
	if currentTrade:
		return null
	currentTrade = Trade.new_instance(player.inventory, Inventory.empty(),
		 onSellLootAction, "Inventory", "Your sell items",
        FileUtil.getContentAsJson(price_list_path))
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
	
func teleportToMissionMap(levelId:int):
	player.teleport("level_" + str(levelId))
	
func teleportToLowerShip():
	player.teleport("ship", Vector3(-1,-3,-12))
	
func removeFromPlayerInventory(id:String, amount:int) -> bool:
	return player.inventory.remove(id, amount)
	
func addToPlayerInventory(id:String, amount:int):
	player.inventory.add(id, amount)
	
func checkPlayerInventory(id:String, minAmount:int):
	return player.inventory.check(id, minAmount)
	
func hasStoreInventoryItems():
	return !player.store_inventory.is_empty()
		
func quitGame():
	save()
	get_tree().quit()

func save():
	player.save()
