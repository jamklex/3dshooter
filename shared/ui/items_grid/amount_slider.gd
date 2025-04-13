extends Panel
class_name AmountSlider

@onready var slider:HSlider = $slider
@onready var itemName:Label = $amount/itemName
@onready var amount:LineEdit = $amount/input
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
	itemName.text = _inventory_item.item.name + ": "
	slider.min_value = 1
	min.text = "1"
	slider.max_value = _inventory_item.amount
	max.text = str(_inventory_item.amount)
	slider.value = 1


func _on_cancel_pressed():
	visible = false

func _on_apply_pressed():
	_submit_input(amount.text)
	on_apply.emit(_inventory_item, slider.value, _rightToLeft)
	_on_cancel_pressed()

func _on_slider_value_changed(value):
	amount.text = str(int(value))

func _on_input_text_submitted(new_text: String) -> void:
	_submit_input(new_text)
	
func _submit_input(new_text: String):
	var new_value = int(new_text)
	if new_value < slider.min_value:
		new_value = slider.min_value
	elif new_value > slider.max_value:
		new_value = slider.max_value
	new_value = int(new_value)
	slider.value = new_value
	amount.text = str(new_value)

func _on_set_to_min_pressed() -> void:
	_submit_input(str(slider.min_value))


func _on_set_to_max_pressed() -> void:
	_submit_input(str(slider.max_value))
