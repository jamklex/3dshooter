extends PanelContainer

const missionCount: int = 10
const missionRotation_mins: int = 15
const max_active: int = 5

@onready var new_missions = $wrapper/new/wrapper/scroll/pc/list
@onready var active_missions = $wrapper/active/wrapper/scroll/pc/list
@onready var expire = $wrapper/new/wrapper/expire
@onready var active_counter = $wrapper/active/wrapper/count
@onready var start_mission = $wrapper/active/wrapper/start_mission
var newMissionUi = preload("res://shared/mission/new_mission.tscn")
var activeMissionUi = preload("res://shared/mission/active_mission.tscn")
var _rng = RandomNumberGenerator.new()

var lastRotationEnd: int
var _known_seeds: Array

func _ready():
	_rng.randomize()
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
	var knownSeeds = WorldUtil.getSavedMissions().map(func(m: Mission): return int(m.getSeed()))
	clear_all_children(new_missions)
	var time = getCurrentRotationEnd(missionRotation_mins)
	for n in range(missionCount):
		var rng = RandomNumberGenerator.new()
		rng.set_seed(time + n)
		if knownSeeds.has(rng.get_seed()):
			continue
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
		ui_wrapper.on_teleport.connect(teleport_to_mission)
		active_missions.add_child(ui_wrapper)
		_known_seeds.push_back(mission.getSeed())
		
func getCurrentEnemyTypes() -> Array[Enemy.ENEMY_TYPE]:
	var availableEnemies: Array[Enemy.ENEMY_TYPE] = []
	for mission in WorldUtil.getSavedMissions():
		if mission.allDone():
			continue
		for enemy in mission.kills:
			# wenn enemies bereits alle gekillt, bitte aus der Liste nehmen (?)
			var type = Enemy.ENEMY_TYPE.values()[int(enemy.id)]
			if !availableEnemies.has(type):
				availableEnemies.append(type)
	return availableEnemies

func reload():
	generate_missions()
	load_saved()

func isReadyForMission() -> bool:
	return true

func _on_start_random_mission_pressed():
	var enemies = {}
	var enemyTypes = getCurrentEnemyTypes()
	if enemyTypes.is_empty():
		enemyTypes = Enemy.ENEMY_TYPE.values()
	for i in range(2):
		var type = enemyTypes.pick_random()
		var value = getCountForType(type)
		if enemies.has(type):
			value += enemies[type]
		enemies[type] = value
	WorldUtil.teleportToMissionMap([str(current_time()), enemies])
	WorldUtil.closeCurrentWindow()

func teleport_to_mission(mission: Mission):
	var enemies = {}
	var targets = mission.kills.filter(func(step: MissionStep): return !step.isDone()) as Array[MissionStep]
	for target in targets:
		var type = Enemy.ENEMY_TYPE.values()[int(target.id)]
		enemies[type] = target.getRest()
	var items = mission.resources.filter(func(step: MissionStep): return !step.isDone()) as Array[MissionStep]
	var additional_item = items.pick_random() as MissionStep
	var additional_items = {}
	if additional_item:
		additional_items = {
			additional_item.id: _rng.randi_range(1, additional_item.getRest())
		}
	WorldUtil.teleportToMissionMap([mission.getSeed(), enemies, additional_items])
	WorldUtil.closeCurrentWindow()

func getCountForType(type: Enemy.ENEMY_TYPE) -> int:
	var rng = RandomNumberGenerator.new()
	match type:
		Enemy.ENEMY_TYPE.WEAK_SQUISHY:
			return rng.randi_range(10, 20)
		Enemy.ENEMY_TYPE.STRONG_SQUISHY:
			return rng.randi_range(10, 20)
		Enemy.ENEMY_TYPE.WEAK_TANK:
			return rng.randi_range(5, 10)
		Enemy.ENEMY_TYPE.STRONG_TANK:
			return rng.randi_range(5, 10)
	return 0

func _on_close_pressed():
	WorldUtil.closeCurrentWindow()
