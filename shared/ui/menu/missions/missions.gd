extends PanelContainer

var missionCount: int = 10
var missionRotation_mins: int = 5

@onready var new_missions = $wrapper/new/list
@onready var active_missions = $wrapper/active/wrapper/scroll/list
var newMissionUi = preload("res://shared/ui/menu/missions/new_mission.tscn")
var activeMissionUi = preload("res://shared/ui/menu/missions/active_mission.tscn")

func _ready():
	var time = getCurrentRotationEnd(missionRotation_mins)
	for n in range(missionCount):
		var rng = RandomNumberGenerator.new()
		rng.set_seed(time + n)
		var mission = Mission.generate(rng)
		# TODO: if not already active
		var ui_wrapper = newMissionUi.instantiate()
		ui_wrapper.link(mission)
		new_missions.add_child(ui_wrapper)

func _process(_delta):
	pass

func getCurrentRotationEnd(rotation_mins: int) -> int:
	var rotation_time = (rotation_mins * 60)
	var time = current_time() + rotation_time
	return time - (time%rotation_time)

func current_time() -> int:
	return int(Time.get_unix_time_from_system())
