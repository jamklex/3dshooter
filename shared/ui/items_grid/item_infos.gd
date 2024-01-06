extends Panel
class_name ItemInfos

@onready var l_name = $name as Label

func _ready():
	visible = false
	
func show_item_infos(item:InventoryItem):
	l_name.text = item.item.name
	visible = true
	
func hide_item_infos():
	visible = false

func _process(delta):
	if not visible:
		return
	var pos = get_global_mouse_position()
	pos.x += 20
	pos.y += 20
	global_position = pos
