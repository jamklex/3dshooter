extends Control
class_name Trade

var onAction: Callable
var playerInventory: Inventory
var otherInventory: Inventory
var priceList:Dictionary
var diffMoney:int = 0
var playerMoney:int = 0
var leftInvName:String
var rightInvName:String

var tradeItemScene = preload("res://shared/trade/tradeItem.tscn")
@onready var playerMoneyLabel = $bg/playerMoney
@onready var diffMoneyLabel = $bg/diffMoney
@onready var leftInvNameLabel = $bg/leftInvName
@onready var rightInvNameLabel = $bg/rightInvName

enum Actions {
	SAVE_TRADE, # has to return boolean true to close trade
	LOAD,
	CLOSE_TRADE,
	CANCEL_PRESSED
}

static func new_instance(playerInv: Inventory, otherInv: Inventory,
		onTradeAction: Callable, priceList: Dictionary = {}, 
		leftInvName: String = "", rightInvName: String = ""):
	var trade = load("res://shared/trade/trade.tscn").instantiate() as Trade
	trade.playerInventory = playerInv.duplicate()
	trade.otherInventory = otherInv.duplicate()
	trade.priceList = priceList
	trade.onAction = onTradeAction
	trade.leftInvName = leftInvName
	trade.rightInvName = rightInvName
	return trade
	
# Called when the node enters the scene tree for the first time.
func _ready():
	onAction.call(Actions.LOAD)
	if priceList:
		var gold_amount = playerInventory.count(Inventory.GOLD_ITEM)
		if gold_amount == 0:
			playerInventory.add(Inventory.GOLD_ITEM, 0)
		playerMoney = gold_amount
	refreshUi()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _moveItemLeftToRightInv(id):
	playerInventory.moveItemSome(otherInventory, id, 1)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney += itemPrice
	refreshUi()
	
func _moveItemRightToLeftInv(id):
	otherInventory.moveItemSome(playerInventory, id, 1)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney -= getPrice(id)
	refreshUi()
	
func getPrice(id):
	if id in priceList:
		return priceList[id]
	return 0

func refreshPlayerInventory():
	var itemContainer = $bg/leftInv/scroll/items as VBoxContainer
	clearItems(itemContainer)
	for id in playerInventory.item_ids():
		if id == Inventory.GOLD_ITEM:
			continue
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(id, playerInventory.count(id))
		tradeItem.onPressed.connect(_moveItemLeftToRightInv)
		itemContainer.add_child(tradeItem)
		
	
func refreshOtherInventory():
	var itemContainer = $bg/rightInv/scroll/items as VBoxContainer
	clearItems(itemContainer)
	for id in otherInventory.item_ids():
		if id == Inventory.GOLD_ITEM:
			continue
		var tradeItem = tradeItemScene.instantiate() as TradeItem
		tradeItem.setItem(id, otherInventory.count(id))
		tradeItem.onPressed.connect(_moveItemRightToLeftInv)
		itemContainer.add_child(tradeItem)
	
func clearItems(itemContainer: VBoxContainer):
	for child in itemContainer.get_children():
		itemContainer.remove_child(child)
	
func refreshUi():
	refreshInventoryLabels()
	refreshPlayerInventory()
	refreshOtherInventory()
	if priceList:
		setMoneyLabelVisibility(true)
		refreshMoneyLabels()
		
func setMoneyLabelVisibility(visible:bool):
	playerMoneyLabel.visible = visible
	diffMoneyLabel.visible = visible
	
func refreshInventoryLabels():
	leftInvNameLabel.text = leftInvName
	rightInvNameLabel.text = rightInvName
	
func refreshMoneyLabels():
	playerMoneyLabel.text = "Gold: " + str(playerMoney)
	diffMoneyLabel.text = ("+" if diffMoney > 0 else "") + str(diffMoney)

func closeTrade():
	onAction.call(Actions.CLOSE_TRADE)
	queue_free()

func _on_cancel_pressed():
	onAction.call(Actions.CANCEL_PRESSED)
	closeTrade()

func _on_done_pressed():
	playerInventory.set_total(Inventory.GOLD_ITEM, playerMoney + diffMoney)
	if (onAction.call(Actions.SAVE_TRADE, [playerInventory, otherInventory])):
		closeTrade()
