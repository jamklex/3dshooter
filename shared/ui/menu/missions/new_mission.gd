extends PanelContainer

var linked_mission: Mission
var kills_holder: Array
var resources_holder: Array
var rewards_holder: Array
@onready var kills = $wrapper/body/kills
@onready var resources = $wrapper/body/resources
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
		add_step(k, kills_holder)
	for r in linked_mission.resources:
		add_step(r, resources_holder)
	for r in linked_mission.rewards:
		var _label = Label.new()
		_label.text = r.item.name + ": " + str(r.amount)
		rewards_holder.push_back(_label)

func add_step(s: MissionStep, parent_holder: Array):
	var step = stepUi.instantiate()
	step.add_link(s)
	parent_holder.push_back(step)

func _process(_delta):
	label.text = linked_mission._name
	for r in resources_holder:
		if(!r.get_parent()):
			resources.add_child(r)
	for k in kills_holder:
		if(!k.get_parent()):
			kills.add_child(k)
	for r in rewards_holder:
		if(!r.get_parent()):
			rewards.add_child(r)
	visible = not active
	if visible and max_active_reached:
		accept.disabled = max_active_reached.call()

func setActive():
	active = true

func _on_accept_button_pressed():
	linked_mission.startMission()
	on_accept.emit()
