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
@onready var playerMoneyElement = $bg/playerMoney
@onready var playerMoneyLabel = $bg/playerMoney/value
@onready var diffMoneyLabel = $bg/diffMoney
@onready var leftInvNameLabel = $bg/leftInvName
@onready var rightInvNameLabel = $bg/rightInvName
@onready var amountSlider:AmountSlider = $bg/AmountSlider
@onready var doneButton:Button = $bg/done
var shopMode = false

enum Actions {
	SAVE_TRADE, # has to return boolean true to close trade
	LOAD,
	CLOSE_TRADE,
	CANCEL_PRESSED
}

static func new_instance(playerInv: Inventory, otherInv: Inventory,
		onTradeAction: Callable, _leftInvName: String = "", _rightInvName: String = "",
		_priceList: Dictionary = {}, shopMode: bool = false):
	var trade = load("res://shared/trade/trade.tscn").instantiate() as Trade
	trade.playerInventory = playerInv.duplicate()
	trade.otherInventory = otherInv.duplicate()
	trade.priceList = _priceList
	trade.onAction = onTradeAction
	trade.leftInvName = _leftInvName
	trade.rightInvName = _rightInvName
	trade.shopMode = shopMode
	return trade

func _ready():
	onAction.call(Actions.LOAD)
	var gold_amount = playerInventory.count(Inventory.GOLD_ITEM)
	if gold_amount == 0:
		playerInventory.add(Inventory.GOLD_ITEM, 0)
	playerMoney = gold_amount
	amountSlider.on_apply.connect(amountSlider_apply)
	refreshUi()
	
func amountSlider_apply(inventory_item:InventoryItem, amount:int, rightToLeft:bool):
	if rightToLeft:
		_moveItemRightToLeftInv_(inventory_item.item.id, amount)
	else:
		_moveItemLeftToRightInv_(inventory_item.item.id, amount)

	
func _moveItemLeftToRightInv_(id:String, amount:int):
	if shopMode:
		playerInventory.remove(id, amount)
	else:
		playerInventory.moveItemSome(otherInventory, id, amount)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney += itemPrice * amount
	refreshUi()
	

func _moveItemRightToLeftInv_(id:String, amount:int):
	if shopMode:
		playerInventory.add(id, amount)
	else:
		otherInventory.moveItemSome(playerInventory, id, amount)
	if priceList:
		var itemPrice = getPrice(id)
		diffMoney -= itemPrice * amount
	refreshUi()
	
func getPrice(id):
	if id in priceList:
		return priceList[id]
	return 0

func _onLeftInventoryItemClicked(inventory_item:InventoryItem, slot_action: Slot.Action):
	if slot_action == Slot.Action.MOVE_CUSTOM_AMOUNT_ITEMS:
		amountSlider.show_slider(inventory_item, false)
	elif slot_action == Slot.Action.MOVE_SINGLE_ITEM:
		_moveItemLeftToRightInv_(inventory_item.item.id, 1)
	elif slot_action == Slot.Action.MOVE_HALF_ITEMS:
		var amount = int(inventory_item.amount/2)
		if amount == 0:
			amount = 1
		_moveItemLeftToRightInv_(inventory_item.item.id, amount)
	elif slot_action == Slot.Action.MOVE_ALL_ITEMS:
		_moveItemLeftToRightInv_(inventory_item.item.id, inventory_item.amount)
		
func _onRightInventoryItemClicked(inventory_item:InventoryItem, slot_action: Slot.Action):
	if shopMode and slot_action == Slot.Action.MOVE_SINGLE_ITEM:
		_moveItemRightToLeftInv_(inventory_item.item.id, inventory_item.amount)
	else:
		if slot_action == Slot.Action.MOVE_CUSTOM_AMOUNT_ITEMS:
				amountSlider.show_slider(inventory_item, true)
		elif slot_action == Slot.Action.MOVE_SINGLE_ITEM:
			_moveItemRightToLeftInv_(inventory_item.item.id, 1)
		elif slot_action == Slot.Action.MOVE_HALF_ITEMS:
			var amount = int(inventory_item.amount/2)
			if amount == 0:
				amount = 1
			_moveItemRightToLeftInv_(inventory_item.item.id, amount)
		elif slot_action == Slot.Action.MOVE_ALL_ITEMS:
			_moveItemRightToLeftInv_(inventory_item.item.id, inventory_item.amount)
	

func refreshPlayerInventory():
	var itemsGrid = $bg/leftInv/items as ItemsGrid
	itemsGrid.show_inventory(playerInventory, not priceList)
	itemsGrid.on_item_clicked.connect(_onLeftInventoryItemClicked)

func refreshOtherInventory():
	var itemsGrid = $bg/rightInv/items as ItemsGrid
	itemsGrid.show_inventory(otherInventory, not priceList)
	itemsGrid.on_item_clicked.connect(_onRightInventoryItemClicked)

func clearItems(itemGrid: VBoxContainer):
	for child in itemGrid.get_children():
		itemGrid.remove_child(child)

func refreshUi():
	refreshInventoryLabels()
	refreshPlayerInventory()
	refreshOtherInventory()
	refreshDoneButton()
	if priceList:
		setMoneyLabelVisibility(true)
		refreshMoneyLabels()

func refreshDoneButton():
	var canDoTrade = playerMoney + diffMoney >= 0
	doneButton.disabled = !canDoTrade
		
func setMoneyLabelVisibility(_visible:bool):
	playerMoneyElement.visible = _visible
	diffMoneyLabel.visible = _visible
	
func refreshInventoryLabels():
	leftInvNameLabel.text = leftInvName
	rightInvNameLabel.text = rightInvName
	
func refreshMoneyLabels():
	var gold_name = ItemHelper.get_item_by_id(Inventory.GOLD_ITEM).name
	playerMoneyLabel.text = gold_name + ": " + str(playerMoney)
	var diffGoldText = ""
	var diffGoldColor = Color.WHITE
	if diffMoney > 0:
		diffGoldText = "+ "
		diffGoldColor = Color.GREEN
	elif diffMoney < 0:
		diffGoldColor = Color.RED
	diffGoldText += str(diffMoney)
	diffGoldText = diffGoldText.replace("-", "- ")
	diffMoneyLabel.text = diffGoldText
	diffMoneyLabel.add_theme_color_override("font_color", diffGoldColor)

func closeTrade():
	onAction.call(Actions.CLOSE_TRADE)
	WorldUtil.closeCurrentWindow()

func _on_cancel_pressed():
	onAction.call(Actions.CANCEL_PRESSED)
	closeTrade()

func _on_done_pressed():
	if priceList:
		playerInventory.set_total(Inventory.GOLD_ITEM, playerMoney + diffMoney)
	if (onAction.call(Actions.SAVE_TRADE, [playerInventory, otherInventory])):
		closeTrade()
