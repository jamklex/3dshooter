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
	InventoryUtil.moveItemComplete(player.store_inventory, player.inventory, "gold")
	var tradeInv = {
		"gold": InventoryUtil.getItemCount(player.inventory, "gold")
	}
	currentTrade = Trade.new_instance(tradeInv, player.store_inventory,
		 onLastLootAction, FileUtil.getContentAsJson(price_list_path),
		"Inventory", "Your saved loot")
	add_child(currentTrade)
	player.body.setInDialog(true)
	return currentTrade

func onLastLootAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		var newPlayerGold = InventoryUtil.getItemCount(payload[0], "gold")
		if newPlayerGold < 0:
			return false
		InventoryUtil.moveAllItems(payload[0], player.inventory)
		player.inventory["gold"] = newPlayerGold
		player.store_inventory = {}
	player.body.setInDialog(false)
	currentTrade = null
	return true

func openSellLoot(price_list_path:String):
	if currentTrade:
		return null
	currentTrade = Trade.new_instance(player.inventory, {},
		 onSellLootAction, FileUtil.getContentAsJson(price_list_path),
		"Inventory", "Your sell items")
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
	
func removeFromPlayerInventory(item:String, amount:int):
	if !checkPlayerInventory(item, amount):
		return false
	player.inventory[item] -= amount
	if !checkPlayerInventory(item, 1):
		player.inventory.erase(item)
	return true
	
func addToPlayerInventory(item:String, amount:int):
	if item in player.inventory:
		player.inventory[item] += amount
	else:
		player.inventory[item] = amount
	
func checkPlayerInventory(item:String, minAmount:int):
	if item in player.inventory:
		return player.inventory[item] >= minAmount
	return false
	
func hasStoreInventoryItems():
	return player.store_inventory.keys().size() > 0
		
func quitGame():
	save()
	get_tree().quit()

func save():
	player.save()
