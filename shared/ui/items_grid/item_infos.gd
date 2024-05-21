extends Panel
class_name ItemInfos

@onready var l_name = $container/name as Label
@onready var l_desc = $container/desc as RichTextLabel

const padding = 20
# screen size can vary, theese numbers ought to handle that
#const height_skew = 2.38
#const width_skew = 4.4

func _ready():
	visible = false
	
func show_item_infos(item:InventoryItem):
	if item:
		l_name.text = item.item.name
		l_desc.text = item.item.description
	visible = true

func hide_item_infos():
	visible = false

func _process(delta):
	if not visible:
		return
	var self_size = size
	var window_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var max_x_pos = window_size.x - self_size.x - padding
	var max_y_pos = window_size.y - self_size.y - padding
	global_position.x = mouse_pos.x + padding
	global_position.y = mouse_pos.y + padding
	if global_position.x > max_x_pos:
		global_position.x = max_x_pos
	if global_position.y > max_y_pos:
		global_position.y = max_y_pos
	if mouse_pos.x > global_position.x and mouse_pos.y > global_position.y:
		global_position.x = mouse_pos.x - self_size.x - padding
	#global_position.x = get_new_pos(mouse_x, size.x * width_skew, window_size.x)
	#global_position.y = get_new_pos(mouse_y, size.y * height_skew, window_size.y)

func get_new_pos(current, buffer, total) -> int:
	return current + padding - max(0, current + buffer + padding - total)
