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
		onTradeAction: Callable, _leftInvName: String = "", _rightInvName: String = "",
		_priceList: Dictionary = {}):
	var trade = load("res://shared/trade/trade.tscn").instantiate() as Trade
	trade.playerInventory = playerInv.duplicate()
	trade.otherInventory = otherInv.duplicate()
	trade.priceList = _priceList
	trade.onAction = onTradeAction
	trade.leftInvName = _leftInvName
	trade.rightInvName = _rightInvName
	return trade

# Called when the node enters the scene tree for the first time.
func _ready():
	onAction.call(Actions.LOAD)
	var gold_amount = playerInventory.count(Inventory.GOLD_ITEM)
	if gold_amount == 0:
		playerInventory.add(Inventory.GOLD_ITEM, 0)
	playerMoney = gold_amount
	refreshUi()

func _moveItemLeftToRightInv(inventory_item:InventoryItem):
	var id = inventory_item.item.id
	playerInventory.moveItemSome(otherInventory, id, 1)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney += itemPrice
	refreshUi()
	
func _moveItemRightToLeftInv(inventory_item:InventoryItem):
	var id = inventory_item.item.id
	otherInventory.moveItemSome(playerInventory, id, 1)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney -= itemPrice
	refreshUi()
	
func getPrice(id):
	if id in priceList:
		return priceList[id]
	return 0

func refreshPlayerInventory():
	var itemsGrid = $bg/leftInv/items as ItemsGrid
	itemsGrid.show_inventory(playerInventory)
	itemsGrid.on_item_clicked.connect(_moveItemLeftToRightInv)
	#clearItems(itemGrid)
	#for id in playerInventory.item_ids():
		#var game_item = ItemHelper.get_item(id)
		#if not game_item.tradeable:
			#continue
		#var tradeItem = tradeItemScene.instantiate() as TradeItem
		#tradeItem.setItem(game_item, playerInventory.count(id))
		#tradeItem.onPressed.connect(_moveItemLeftToRightInv)
		#itemGrid.add_child(tradeItem)

func refreshOtherInventory():
	var itemsGrid = $bg/rightInv/items
	itemsGrid.show_inventory(otherInventory)
	itemsGrid.on_item_clicked.connect(_moveItemRightToLeftInv)
	#clearItems(itemGrid)
	#for id in otherInventory.item_ids():
		#var game_item = ItemHelper.get_item(id)
		#var tradeItem = tradeItemScene.instantiate() as TradeItem
		#tradeItem.setItem(game_item, otherInventory.count(id))
		#tradeItem.onPressed.connect(_moveItemRightToLeftInv)
		#itemGrid.add_child(tradeItem)

func clearItems(itemGrid: VBoxContainer):
	for child in itemGrid.get_children():
		itemGrid.remove_child(child)

func refreshUi():
	refreshInventoryLabels()
	refreshPlayerInventory()
	refreshOtherInventory()
	if priceList:
		setMoneyLabelVisibility(true)
		refreshMoneyLabels()
		
func setMoneyLabelVisibility(_visible:bool):
	playerMoneyLabel.visible = _visible
	diffMoneyLabel.visible = _visible
	
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
