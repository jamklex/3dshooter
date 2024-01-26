extends PanelContainer

const missionCount: int = 10
const missionRotation_mins: int = 15
const max_active: int = 5

@onready var new_missions = $wrapper/new/wrapper/scroll/list
@onready var active_missions = $wrapper/active/wrapper/scroll/list
@onready var expire = $wrapper/new/wrapper/expire
@onready var active_counter = $wrapper/active/wrapper/count
@onready var start_mission = $wrapper/active/wrapper/start_mission
var newMissionUi = preload("res://shared/mission/new_mission.tscn")
var activeMissionUi = preload("res://shared/mission/active_mission.tscn")

var lastRotationEnd: int
var _known_seeds: Array

func _ready():
	reload()

func _process(_delta):
	var now = current_time()
	if lastRotationEnd and lastRotationEnd <= now:
		generate_missions()
	var rotationEnd = getCurrentRotationEnd(missionRotation_mins)
	var time = Time.get_datetime_dict_from_unix_time(rotationEnd - now)
	var h = str(time.get("hour")).pad_zeros(2)
	var m = str(time.get("minute")).pad_zeros(2)
	var s = str(time.get("second")).pad_zeros(2)
	expire.set_text("Refresh in %s:%s:%s" % [h,m,s])
	lastRotationEnd = rotationEnd
	active_counter.text = str(get_active_count()) + "/" + str(max_active)
	start_mission.disabled = not isReadyForMission()

func getCurrentRotationEnd(rotation_mins: int) -> int:
	var rotation_time = (rotation_mins * 60)
	var time = current_time() + rotation_time
	return time - (time%rotation_time)

func current_time() -> int:
	return int(Time.get_unix_time_from_system())

func clear_all_children(parent):
	for child in parent.get_children():
		parent.remove_child(child)

func generate_missions():
	clear_all_children(new_missions)
	var time = getCurrentRotationEnd(missionRotation_mins)
	for n in range(missionCount):
		var rng = RandomNumberGenerator.new()
		rng.set_seed(time + n)
		var mission = Mission.generate(rng)
		var ui_wrapper = newMissionUi.instantiate()
		ui_wrapper.link(mission, Callable(max_missions_reached))
		ui_wrapper.on_accept.connect(reload)
		if _known_seeds.has(mission.getSeed()):
			ui_wrapper.setActive()
		new_missions.add_child(ui_wrapper)

func get_active_count() -> int:
	return active_missions.get_child_count()

func max_missions_reached() -> bool:
	return get_active_count() >= max_active

func load_saved():
	clear_all_children(active_missions)
	_known_seeds.clear()
	for mission in WorldUtil.getSavedMissions():
		var ui_wrapper = activeMissionUi.instantiate()
		ui_wrapper.link(mission)
		active_missions.add_child(ui_wrapper)
		_known_seeds.push_back(mission.getSeed())

func reload():
	print("reload")
	load_saved()
	generate_missions()

func isReadyForMission() -> bool:
	return true

func _on_start_mission_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	WorldUtil.teleportToMissionMap([rng.seed,5])
	queue_free()
