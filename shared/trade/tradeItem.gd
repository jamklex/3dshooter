extends Button
class_name TradeItem

signal onPressed
var _item: GameItem
var _itemId
var _itemCount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setItem(item: GameItem, amount):
	_itemId = item.id
	_item = item
	_itemCount = amount
	_setText(str(_itemCount) + "x " + _item.name)

func _setText(newText):
	text = newText

func _on_pressed():
	onPressed.emit(_itemId)
