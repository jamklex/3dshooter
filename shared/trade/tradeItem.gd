extends Button
class_name TradeItem

signal onPressed
var _itemName
var _itemCount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setItem(itemName, itemCount):
	_itemName = itemName
	_itemCount = itemCount
	_setText(str(_itemCount) + "x " + _itemName)
	
func _setText(newText):
	text = newText

func _on_pressed():
	onPressed.emit(_itemName)
