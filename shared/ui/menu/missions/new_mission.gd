extends PanelContainer

var linked_mission: Mission
var _steps: Array
@onready var steps = $wrapper/body/steps
@onready var rewards = $wrapper/body/rewards
@onready var accept = $wrapper/header/accept_button
@onready var label = $wrapper/header/label as Label
var stepUi = preload("res://shared/ui/menu/missions/new_step.tscn")
var active: bool = false
signal on_accept
var max_active_reached: Callable

func link(mission: Mission, _max_active_reached: Callable):
	linked_mission = mission
	max_active_reached = _max_active_reached
	for k in linked_mission.kills:
		add_step("Kill Monster ", k)
	for r in linked_mission.resources:
		add_step("Get Resource ", r)

func add_step(prefix: String, s: MissionStep):
	var step = stepUi.instantiate()
	step.add_link(prefix, s)
	_steps.push_back(step)

func _process(_delta):
	label.text = linked_mission._name
	for s in _steps:
		if(!s.get_parent()):
			steps.add_child(s)
	visible = not active
	if visible and max_active_reached:
		accept.disabled = max_active_reached.call()

func setActive():
	active = true

func _on_accept_button_pressed():
	linked_mission.startMission()
	on_accept.emit()
