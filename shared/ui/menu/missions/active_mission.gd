extends PanelContainer

@onready var label = $ordering/header/label as Label
@onready var collect_button = $ordering/header/collect_button as Button
@onready var steps = $ordering/body/steps as VBoxContainer
var linked_mission: Mission
var _steps: Array

const active_color = Color("#9558224b")
const expired_color = Color("#b5323b4b")
const done_color = Color("#4a76424b")
const colors = [active_color, expired_color, done_color]
var stepUi = preload("res://shared/ui/menu/missions/step.tscn")

func _ready():
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate(true))
	set_bg_color(colors.pick_random())

func _process(_delta):
	for s in _steps:
		if(!s.get_parent()):
			steps.add_child(s)
	if linked_mission and linked_mission.allDone():
		set_bg_color(done_color)
		if _on_ship():
			_allow_collect()

func link(mission: Mission):
	linked_mission = mission
	for k in linked_mission.kills:
		add_step("Kill Monster ", k)
	for r in linked_mission.resources:
		add_step("Get Resource ", r)

func add_step(prefix: String, s: MissionStep):
	var step = stepUi.instantiate()
	step.add_link(prefix, s)
	_steps.push_back(step)

func _is_done() -> bool:
	return false

func _on_ship() -> bool:
	return false

func set_bg_color(color: Color):
	get_theme_stylebox("panel").bg_color = color

func _allow_collect():
	pass
