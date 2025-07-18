extends Button
class_name Slot

signal clicked(inventory_item:InventoryItem, slot_action: Slot.Action)
signal mouseHovered(inventory_item:InventoryItem)
signal mouseExited(inventory_item:InventoryItem)
@onready var _image:TextureRect = $image
@onready var _amount:Label = $amount
@export var show_amount: bool = true
var _inventory_item: InventoryItem = null

enum Action {
	MOVE_ALL_ITEMS,
	MOVE_HALF_ITEMS,
	MOVE_SINGLE_ITEM,
	MOVE_CUSTOM_AMOUNT_ITEMS,
}

func clear():
	_inventory_item = null
	_image.texture = null
	_amount.text = ""
	
func show_item(inventory_item:InventoryItem):
	_inventory_item = inventory_item
	refresh()
	
func refresh():
	if not _inventory_item:
		_image.texture = null
		_amount.text = ""
		return
	_image.texture = _inventory_item.item.image
	if show_amount and _inventory_item.amount > 1:
		_amount.text = str(_inventory_item.amount) + "x"
	else:
		_amount.text = ""

func is_empty():
	return _inventory_item == null

func _on_mouse_entered():
	mouseHovered.emit(_inventory_item)

func _on_mouse_exited():
	mouseExited.emit(_inventory_item)

func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mouseButtonEvent = event as InputEventMouseButton
	if Input.is_action_just_pressed("moveAllItems"):
		clicked.emit(_inventory_item, Action.MOVE_ALL_ITEMS)
	elif Input.is_action_just_pressed("moveHalfItems"):
		clicked.emit(_inventory_item, Action.MOVE_HALF_ITEMS)
	elif Input.is_action_just_pressed("moveCustomAmountItems"):
		clicked.emit(_inventory_item, Action.MOVE_CUSTOM_AMOUNT_ITEMS)
	elif Input.is_action_just_pressed("moveSingleItem"):
		clicked.emit(_inventory_item, Action.MOVE_SINGLE_ITEM)
	
