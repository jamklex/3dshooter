extends PanelContainer

@onready var label = $ordering/header/label as Label
@onready var expire = $ordering/expire as Label
@onready var collect_button = $ordering/header/collect_button as Button
@onready var remove_button = $ordering/header/remove_button as Button
@onready var kills = $ordering/body/kills as VBoxContainer
@onready var resources = $ordering/body/resources as VBoxContainer
@onready var rewards = $ordering/body/rewards as VBoxContainer
@onready var punishments = $ordering/body/punishments as VBoxContainer
var linked_mission: Mission
var kills_holder: Array
var resources_holder: Array
var rewards_holder: Array
var punishment_holder: Array

const active_color = Color("#9558224b")
const expired_color = Color("#b5323b4b")
const done_color = Color("#4a76424b")
const colors = [active_color, expired_color, done_color]
var stepUi = preload("res://shared/ui/menu/missions/step.tscn")

func _ready():
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate(true))
	set_bg_color(active_color)

func _process(_delta):
	var is_over = linked_mission.isOver()
	collect_button.visible = !is_over
	rewards.visible = !is_over
	remove_button.visible = is_over
	punishments.visible = is_over
	if not is_over:
		refresh_timer()
	else:
		expire.set_text("00:00:00")
	label.text = linked_mission._name
	for k in kills_holder:
		if(!k.get_parent()):
			kills.add_child(k)
	for r in resources_holder:
		if(!r.get_parent()):
			resources.add_child(r)
	for r in rewards_holder:
		if(!r.get_parent()):
			rewards.add_child(r)
	for p in punishment_holder:
		if(!p.get_parent()):
			punishments.add_child(p)
	if linked_mission and linked_mission.allDone():
		set_bg_color(done_color)
		collect_button.disabled = true

func clear(_parent: Node):
	for c in _parent.get_children():
		_parent.remove_child(c)

func refresh_timer():
	var now = int(Time.get_unix_time_from_system())
	var time = Time.get_datetime_dict_from_unix_time(linked_mission.over - now)
	var h = str(time.get("hour")).pad_zeros(2)
	var m = str(time.get("minute")).pad_zeros(2)
	var s = str(time.get("second")).pad_zeros(2)
	expire.set_text("%s:%s:%s" % [h,m,s])

func link(mission: Mission):
	linked_mission = mission
	for k in linked_mission.kills:
		add_step(k, kills_holder)
	for r in linked_mission.resources:
		add_step(r, resources_holder)
	for r in linked_mission.rewards:
		var _label = Label.new()
		_label.text = r.item.name + ": " + str(r.amount)
		rewards_holder.push_back(_label)
	for p in linked_mission.getPunishment():
		var _label = Label.new()
		_label.add_theme_color_override("font_color", Color.RED)
		_label.text = p.item.name + ": -" + str(p.amount)
		punishment_holder.push_back(_label)

func add_step(s: MissionStep, _parent: Array):
	var step = stepUi.instantiate()
	step.add_link(s)
	_parent.push_back(step)

func _is_done() -> bool:
	return false

func _on_ship() -> bool:
	return false

func set_bg_color(color: Color):
	get_theme_stylebox("panel").bg_color = color

func _on_remove_button_pressed():
	var missions = FileUtil.getContentAsJson(WorldUtil.missionsSavePath, false) as Dictionary
	missions.erase(linked_mission.getSeed())
	FileUtil.saveJsonContent(WorldUtil.missionsSavePath, missions)
	queue_free()
