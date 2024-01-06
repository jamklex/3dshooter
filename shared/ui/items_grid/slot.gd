extends Button
class_name Slot

signal clicked(inventory_item:InventoryItem)
@onready var _image:TextureRect = $image
@onready var _amount:Label = $amount
var _inventory_item: InventoryItem = null

func clear():
	_inventory_item = null
	_image.texture = null
	_amount.text = ""
	
func show_item(inventory_item:InventoryItem):
	_inventory_item = inventory_item
	refresh()
	
func refresh():
	if not _inventory_item:
		return
	_image.texture = _inventory_item.item.image
	_amount.text = str(_inventory_item.amount) + "x"

func is_empty():
	return _inventory_item == null


func _on_pressed():
	clicked.emit(_inventory_item)
