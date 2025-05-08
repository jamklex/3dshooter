extends PanelContainer

var linked_mission: Mission
var kills_holder: Array
var resources_holder: Array
var rewards_holder: Array

@onready var accept = $wrapper/header/accept_button
@onready var label = $wrapper/header/label as Label

@onready var kills = $wrapper/body/kills/body
@onready var resources = $wrapper/body/resources/body
@onready var rewards = $wrapper/body/rewards/body

@export_category("Steps")
@export var resourcesColor: Color = Color("fff")
@export var killsColor: Color = Color("fff")
@export var rewardsColor: Color = Color("fff")

@export_category("Difficulties")
@export var easyBackground: Color = Color("fff")
@export var mediumBackground: Color = Color("fff")
@export var hardBackground: Color = Color("fff")

var stepUi = preload("res://shared/mission/new_step.tscn")
var active: bool = false
signal on_accept
var max_active_reached: Callable

func link(mission: Mission, _max_active_reached: Callable):
	linked_mission = mission
	set_background()
	max_active_reached = _max_active_reached
	for k in linked_mission.kills:
		add_step(k, kills_holder, killsColor)
	for r in linked_mission.resources:
		add_step(r, resources_holder, resourcesColor)
	for r in linked_mission.rewards:
		var _label = Label.new()
		set_color(_label, rewardsColor)
		_label.text = r.item.name + ": " + str(r.amount)
		rewards_holder.push_back(_label)

func add_step(s: MissionStep, parent_holder: Array, color: Color):
	var step = stepUi.instantiate()
	step.add_link(s)
	step.color = color
	parent_holder.push_back(step)

func set_color(label: Label, color: Color):
	label.add_theme_color_override("font_color", color)

func set_background():
	var styleBox = get_theme_stylebox("panel").duplicate(true) as StyleBoxFlat
	set("theme_override_styles/panel", styleBox)
	match linked_mission.difficulty:
		Mission.Difficulty.EASY:
			styleBox.set_bg_color(easyBackground)
		Mission.Difficulty.MEDIUM:
			styleBox.set_bg_color(mediumBackground)
		Mission.Difficulty.HARD:
			styleBox.set_bg_color(hardBackground)

func _process(_delta):
	var difficulty = Mission.Difficulty.find_key(linked_mission.difficulty)
	label.text = "[" + difficulty + "]\n" + linked_mission._name
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
