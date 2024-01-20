extends PanelContainer

@onready var label = $ordering/header/label as Label
@onready var expire = $ordering/expire as Label
@onready var collect_button = $ordering/header/collect_button as Button
@onready var remove_button = $ordering/header/remove_button as Button
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
	set_bg_color(active_color)

func _process(_delta):
	var is_over = linked_mission.isOver()
	remove_button.visible = is_over
	collect_button.visible = !is_over
	if not is_over:
		refresh_timer()
	label.text = linked_mission._name
	for s in _steps:
		if(!s.get_parent()):
			steps.add_child(s)
	if linked_mission and linked_mission.allDone():
		set_bg_color(done_color)
		if _on_ship():
			_allow_collect()

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
	collect_button.disabled = false

func _on_remove_button_pressed():
	var missions = FileUtil.getContentAsJson(WorldUtil.missionsSavePath, false) as Dictionary
	missions.erase(linked_mission.getSeed())
	FileUtil.saveJsonContent(WorldUtil.missionsSavePath, missions)
	queue_free()
