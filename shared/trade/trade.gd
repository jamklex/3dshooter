extends Control
class_name Trade

var onAction: Callable
var playerInventory: Dictionary
var otherInventory: Dictionary
var priceList:Dictionary
var diffMoney:int = 0
var playerMoney:int = 0

var tradeItemScene = preload("res://shared/trade/tradeItem.tscn")
@onready var playerMoneyLabel = $bg/playerMoney
@onready var diffMoneyLabel = $bg/diffMoney

enum Actions {
	SAVE_TRADE, # has to return boolean true to close trade
	LOAD,
	CLOSE_TRADE,
	CANCEL_PRESSED
}

static func new_instance(playerInv: Dictionary, otherInv: Dictionary,
			 onTradeAction: Callable, priceList: Dictionary = {}):
	var trade = load("res://shared/trade/trade.tscn").instantiate() as Trade
	trade.playerInventory = playerInv.duplicate(true)
	trade.otherInventory = otherInv.duplicate(true)
	trade.priceList = priceList
	trade.onAction = onTradeAction
	return trade
	
# Called when the node enters the scene tree for the first time.
func _ready():
	onAction.call(Actions.LOAD)
	if priceList:
		if not "gold" in playerInventory:
			playerInventory["gold"] = 0
		playerMoney = playerInventory["gold"]
	refreshUi()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _moveItemLeftToRightInv(itemName):
	InventoryUtil.moveItems(playerInventory, otherInventory, itemName, 1)
	if priceList:
		var itemPrice = getPrice(itemName)
		diffMoney += itemPrice
		playerInventory["gold"] += itemPrice
	refreshUi()
	
func _moveItemRightToLeftInv(itemName):
	InventoryUtil.moveItems(otherInventory, playerInventory, itemName, 1)
	if priceList:
		var itemPrice = getPrice(itemName)
		diffMoney -= getPrice(itemName)
		playerInventory["gold"] -= itemPrice
	refreshUi()
	
func getPrice(itemName):
	if itemName in priceList:
		return priceList[itemName]
	return 0

func refreshPlayerInventory():
	var itemContainer = $bg/leftInv/scroll/items as VBoxContainer
	clearItems(itemContainer)
	for itemName in playerInventory.keys():
		if itemName == "gold":
			continue
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(itemName, playerInventory[itemName])
		tradeItem.onPressed.connect(_moveItemLeftToRightInv)
		itemContainer.add_child(tradeItem)
		
	
func refreshOtherInventory():
	var itemContainer = $bg/rightInv/scroll/items as VBoxContainer
	clearItems(itemContainer)
	for itemName in otherInventory.keys():
		if itemName == "gold":
			continue
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(itemName, otherInventory[itemName])
		tradeItem.onPressed.connect(_moveItemRightToLeftInv)
		itemContainer.add_child(tradeItem)
	
func clearItems(itemContainer: VBoxContainer):
	for child in itemContainer.get_children():
		itemContainer.remove_child(child)
	
func refreshUi():
	refreshPlayerInventory()
	refreshOtherInventory()
	if priceList:
		setMoneyLabelVisibility(true)
		refreshMoneyLabels()
		
func setMoneyLabelVisibility(visible:bool):
	playerMoneyLabel.visible = visible
	diffMoneyLabel.visible = visible
	
func refreshMoneyLabels():
	playerMoneyLabel.text = "Gold: " + str(playerMoney)
	diffMoneyLabel.text = ("+" if diffMoney > 0 else "") + str(diffMoney)

func closeTrade():
	onAction.call(Actions.CLOSE_TRADE)
	self.queue_free()

func _on_cancel_pressed():
	onAction.call(Actions.CANCEL_PRESSED)
	closeTrade()

func _on_done_pressed():
	if (onAction.call(Actions.SAVE_TRADE, [playerInventory, otherInventory])):
		closeTrade()
