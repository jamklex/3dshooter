extends Node

var player: Player = Player.new()
var currentDialog: Dialog
var currentTrade: Trade
var quests: Array

func _enter_tree():
	add_child(player)

func createDialog(npc_id:String, dialog_data_path:String) -> Dialog:
	if !currentDialog:
		currentDialog = Dialog.new_instance(dialog_data_path, Callable(player.body, "setInDialog"))
		add_quest_dialogs(npc_id, currentDialog)
		currentDialog.load_dialog_data()
		add_child(currentDialog)
	return currentDialog

func add_quest_dialogs(npc_id, currentDialog):
	for _quest in get_quests():
		if !_quest.active:
			continue
		for _task in _quest.tasks:
			var additional_dialog = _task.dialog as TaskDialog
			if !_task.is_active() or !additional_dialog or additional_dialog.npc != npc_id:
				continue
			currentDialog.add_options(additional_dialog.get_dialog_key(), additional_dialog.as_dialog_options())

func get_quests():
	if !clear_nulls(quests):
		quests = QuestLoader.load_quests("res://data/quests")
	return quests

func clear_nulls(_array: Array):
	for object in _array:
		if !is_instance_valid(object):
			_array.erase(object)
	return _array

# generic methods under this line #
###################################

func openLastLoot(payload: Array):
	if currentTrade:
		return null
	player.store_inventory.moveItem(player.inventory, Inventory.GOLD_ITEM)
	var tradeInv = Inventory.from({
		Inventory.GOLD_ITEM: player.inventory.count(Inventory.GOLD_ITEM)
	})
	currentTrade = Trade.new_instance(tradeInv, player.store_inventory,
		onLastLootAction, "Inventory", "Your saved loot",
		FileUtil.getContentAsJson(payload[0]))
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
	player.teleport("level_" + str(payload[0]))
	
func teleportToLowerShip(payload: Array = []):
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
	
func hasStoreInventoryItems(payload: Array = []):
	return !player.store_inventory.is_empty()

func quitGame():
	save()
	get_tree().quit()

func save():
	player.save()
