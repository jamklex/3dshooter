extends Panel
class_name ItemInfos

@onready var l_name = $container/name as Label
@onready var l_desc = $container/desc as RichTextLabel

const padding = 20
# screen size can vary, theese numbers ought to handle that
const height_skew = 2.38
const width_skew = 4.4

func _ready():
	visible = false
	
func show_item_infos(item:InventoryItem):
	l_name.text = item.item.name
	l_desc.text = item.item.description
	visible = true

func hide_item_infos():
	visible = false

func _process(delta):
	if not visible:
		return
	var window_size = get_window().size
	var mouse_x = get_global_mouse_position().x
	var mouse_y = get_global_mouse_position().y
	global_position.x = get_new_pos(mouse_x, size.x * width_skew, window_size.x)
	global_position.y = get_new_pos(mouse_y, size.y * height_skew, window_size.y)

func get_new_pos(current, buffer, total) -> int:
	return current + padding - max(0, current + buffer - total)
