extends PanelContainer

@onready var label = $ordering/header/label as Label
@onready var collect_button = $ordering/header/collect_button as Button
@onready var steps = $ordering/body/steps as VBoxContainer
var linked_mission: Mission

const active_color = Color("#9558224b")
const expired_color = Color("#b5323b4b")
const done_color = Color("#4a76424b")
const colors = [active_color, expired_color, done_color]

func _ready():
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate(true))
	set_bg_color(colors.pick_random())

func _process(delta):
	if linked_mission and linked_mission.allDone():
		set_bg_color(done_color)
		if _on_ship():
			_allow_collect()

func _is_done() -> bool:
	return false

func _on_ship() -> bool:
	return false

func set_bg_color(color: Color):
	get_theme_stylebox("panel").bg_color = color

func _allow_collect():
	pass
