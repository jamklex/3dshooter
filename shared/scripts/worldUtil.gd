extends Node



var player: Player = Player.new()
var currentDialog: Dialog
var dialogScene = preload("res://shared/dialog/dialog.tscn")
var currentTrade: Trade

func _enter_tree():
	add_child(player)

func createDialog(dialog_data_path:String) -> Dialog:
	if currentDialog:
		return null
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
	currentTrade = Trade.new_instance(player.inventory, player.store_inventory, onTradeAction)
#	currentTrade.setPriceList({
#		"item_123123": 12
#	})
	add_child(currentTrade)
	player.isInConversation = true
	player.body.setInDialog(true)
	return currentTrade

func onTradeAction(action: Trade.TradeActions, payload: Array = []):
	pass

func applyTrade(newPlayerInv:Dictionary, newOtherInv: Dictionary):
	player.inventory = newPlayerInv
	player.store_inventory = newOtherInv
	
func deleteTrade():
	remove_child(currentTrade)
	currentTrade.queue_free()
	player.isInConversation = false
	player.body.setInDialog(false)
	
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
