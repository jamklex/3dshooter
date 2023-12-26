extends Panel

@onready var slider:HSlider = $slider
@onready var amount:Label = $amount
@onready var min:Label = $min
@onready var max:Label = $max
signal on_apply(inventory_item:InventoryItem, amount:int, rightToLeft:bool)
var _inventory_item:InventoryItem = null
var _rightToLeft = false


func _ready():
	visible = false

func show_slider(inventory_item:InventoryItem, rightToLeft:bool):
	_inventory_item = inventory_item
	_rightToLeft = rightToLeft
	_show_info()
	visible = true
	
func _show_info():
	slider.min_value = 1
	min.text = "1"
	slider.max_value = _inventory_item.amount
	max.text = str(_inventory_item.amount)
	slider.value = 1


func _on_cancel_pressed():
	visible = false

func _on_apply_pressed():
	on_apply.emit(_inventory_item, slider.value, _rightToLeft)
	_on_cancel_pressed()

func _on_slider_value_changed(value):
	amount.text = _inventory_item.item.name + ": " + str(int(value))
