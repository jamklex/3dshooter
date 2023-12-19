@tool
extends Panel
class_name ItemsGrid



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
	print("rows", rows)
	print("columns", columns)
	var container = get_node("ScrollContainer/MarginContainer/slots") as GridContainer
	for slot in container.get_children():
		container.remove_child(slot)
	container.columns = columns
	var total_slots = rows * columns
	var slot_scene = load("res://shared/ui/items_grid/slot.tscn") as PackedScene
	for i in range(total_slots):
		var slot = slot_scene.instantiate()
		container.add_child(slot)
