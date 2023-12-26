extends Panel
class_name ItemInfo

@onready var item_name:Label = $name

func show_item_info(inventory_item:InventoryItem):
	if not inventory_item:
		return
	_show_item_info(inventory_item)

func clear():
	item_name.text = "Click on an item"
	
func _show_item_info(inventory_item:InventoryItem):
	item_name.text = inventory_item.item.name
