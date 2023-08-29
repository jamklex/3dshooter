extends Node


var player: Player = Player.new()
var currentDialog: Dialog
var dialogScene = preload("res://shared/dialog/dialog.tscn")
var currentTrade: Trade
var testPriceList = {
	"item_goldenSphere": 10,
	"too_expensive": 110
}

func _enter_tree():
	add_child(player)

func createDialog(dialog_data_path:String) -> Dialog:
	currentDialog = dialogScene.instantiate()
	currentDialog.loadDialogData(dialog_data_path)
	add_child(currentDialog)
	player.isInConversation = true
	return currentDialog

func deleteDialog():
	remove_child(currentDialog)
	currentDialog = null
	player.isInConversation = false
	
func openLastLootInventory():
	if currentTrade:
		return null
	InventoryUtil.moveAllItems(player.store_inventory, player.inventory, "gold")
	currentTrade = Trade.new_instance(player.inventory, player.store_inventory,
		 onTradeAction, testPriceList)
	add_child(currentTrade)
	player.isInConversation = true
	player.body.setInDialog(true)
	return currentTrade

func onTradeAction(action: Trade.Actions, payload: Array = []):
	if action != Trade.Actions.SAVE_TRADE and action != Trade.Actions.CANCEL_PRESSED:
		return
	if action == Trade.Actions.SAVE_TRADE:
		var newPlayerGold = InventoryUtil.getItemCount(payload[0], "gold")
		if newPlayerGold < 0:
			return false
		player.inventory = payload[0]
		player.store_inventory = payload[1]
	player.isInConversation = false
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
		
func save():
	player.save()
