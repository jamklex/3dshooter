extends Control
class_name Trade

signal onDone
var _playerInventory: Dictionary
var _otherInventory: Dictionary
var _priceList:Dictionary
var _tradeVal:int = 0

var tradeItemScene = preload("res://shared/trade/tradeItem.tscn")

static func new_instance(playerInv: Dictionary, otherInv: Dictionary):
	var trade = load("res://shared/trade/trade.tscn").instantiate()
	trade.setPlayerInventory(playerInv)
	trade.setOtherInventory(otherInv)
	return trade

func setPlayerInventory(playerInventory:Dictionary):
	_playerInventory = playerInventory.duplicate(true)
	
func setOtherInventory(otherInventory:Dictionary):
	_otherInventory = otherInventory.duplicate(true)
	
func setPriceList(priceList:Dictionary):
	_priceList = priceList
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_load()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _moveItemLeftToRightInv(itemName):
	removeFromInventory(_playerInventory, itemName)
	addToInventory(_otherInventory, itemName)
	_refreshInventories()
	
func _moveItemRightToLeftInv(itemName):
	removeFromInventory(_otherInventory, itemName)
	addToInventory(_playerInventory, itemName)
	_refreshInventories()

func _refreshplayerInventory():
	var itemContainer = $bg/leftInv/scroll/items as VBoxContainer
	_clearItems(itemContainer)
	for leftItemName in _playerInventory.keys():
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(leftItemName, _playerInventory[leftItemName])
		tradeItem.onPressed.connect(_moveItemLeftToRightInv)
		itemContainer.add_child(tradeItem)
		
	
func _refreshotherInventory():
	var itemContainer = $bg/rightInv/scroll/items as VBoxContainer
	_clearItems(itemContainer)
	for leftItemName in _otherInventory.keys():
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(leftItemName, _otherInventory[leftItemName])
		tradeItem.onPressed.connect(_moveItemRightToLeftInv)
		itemContainer.add_child(tradeItem)
	
func _clearItems(itemContainer: VBoxContainer):
	for child in itemContainer.get_children():
		itemContainer.remove_child(child)
	
func _refreshInventories():
	_refreshplayerInventory()
	_refreshotherInventory()
	
func _checkIfMoneyTrade():
	if _priceList:
		print("its a money trade")
	else:
		print("its NOT a money trade")

func _load():
	_refreshInventories()
	_checkIfMoneyTrade()

func _closeTrade():
	WorldUtil.deleteTrade()

func _on_cancel_pressed():
	_closeTrade()
	
func _playerMoneyIsNegativ(_tradeVal):
	return WorldUtil.player.money + _tradeVal >= 0

func _on_done_pressed():
	if _checkIfMoneyTrade() and _playerMoneyIsNegativ(_tradeVal):
		print("player has not enough money")
		return
	WorldUtil.player.money += _tradeVal
	onDone.emit(_playerInventory, _otherInventory)
	_closeTrade()

func removeFromInventory(inv:Dictionary, item:String):
	var amount = 1
	if !checkInventory(inv, item):
		return false
	inv[item] -= amount
	if !checkInventory(inv, item):
		inv.erase(item)
	return true
	
func addToInventory(inv:Dictionary, item:String):
	var amount = 1
	if item in inv:
		inv[item] += amount
	else:
		inv[item] = amount
	
func checkInventory(inv:Dictionary, item:String):
	var minAmount = 1
	if item in inv:
		return inv[item] >= minAmount
	return false
