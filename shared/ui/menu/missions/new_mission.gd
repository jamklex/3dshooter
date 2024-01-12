extends PanelContainer

var linked_mission: Mission

var _steps: Array
@onready var steps = $wrapper/body/steps
@onready var rewards = $wrapper/body/steps
var stepUi = preload("res://shared/ui/menu/missions/step.tscn")

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

func _process(_delta):
	for s in _steps:
		if(!s.get_parent()):
			steps.add_child(s)
