@tool
extends Panel
class_name ItemsGrid

signal on_item_clicked(inventory_item:InventoryItem)
var _inventory:Inventory = null
@onready var _container:GridContainer = $ScrollContainer/MarginContainer/slots

@export_range(1,20) var columns = 1:
	set(new_columns):
		print("set columns")
		columns = new_columns
		_init_slots()
		
@export_range(1,20) var rows = 1:
	set(new_rows):
		print("set rows")
		rows = new_rows
		_init_slots()
		
func _init_slots():
	_container = get_node("ScrollContainer/MarginContainer/slots") as GridContainer
	for slot in _get_slots():
		_container.remove_child(slot)
	_container.columns = columns
	var total_slots = rows * columns
	var slot_scene = load("res://shared/ui/items_grid/slot.tscn") as PackedScene
	for i in range(total_slots):
		var slot = slot_scene.instantiate() as Slot
		_container.add_child(slot)
	for slot in _get_slots():
		slot.clicked.connect(_on_slot_clicked)
		
func _on_slot_clicked(inventory_item:InventoryItem):
	on_item_clicked.emit(inventory_item)
		
func _get_slots():
	var slots = []
	for child in _container.get_children():
		slots.append(child)
	return slots
	
func _get_empty_slot():
	for slot in _get_slots():
		if slot.is_empty():
			return slot
	return null
		
func show_inventory(inventory:Inventory):
	print("show_inventory")
	_inventory = inventory
	refresh()

func refresh():
	print("refresh")
	if not _inventory:
		print("no inventory")
		return
	for slot in _get_slots():
		slot.clear()
	print("slots cleard")
	for item in _inventory.items.values():
		var inventory_item = item as InventoryItem
		var empty_slot = _get_empty_slot()
		if not empty_slot:
			print("no empty slot")
			return
		empty_slot.show_item(inventory_item)
		print("item added")
