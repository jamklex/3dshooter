extends Container
class_name KillCounter


@onready var background = $Background
@onready var entries_holder = $Background/Margin/Content/entriesHolder
const entry_template = preload("res://shared/ui/kill_counter/kill_counter_entry.tscn")
var on_enemy_killed_callback = Callable(self, "on_enemy_killed")
var total_enemies: Dictionary = {}
var killed_enemies: Dictionary = {}

func on_enemy_killed(enemy_type: Enemy.ENEMY_TYPE):
	var killed_amount = killed_enemies.get(enemy_type, 0)
	killed_amount += 1
	killed_enemies.set(enemy_type, killed_amount)
	_refresh_kill_counter()

func _ready():
	if not WorldUtil.player.inMissionMap:
		return
	WorldUtil.add_on_enemy_died_callback(on_enemy_killed_callback)
	total_enemies = WorldUtil.current_prg.get_total_enemies()
	_refresh_kill_counter()

func _exit_tree() -> void:
	WorldUtil.remove_on_enemy_died_callback(on_enemy_killed_callback)
		
func _refresh_kill_counter():
	_cleanEntries()
	for enemy_type in total_enemies.keys():
		var total_amount = total_enemies.get(enemy_type)
		if total_amount == null:
			continue
		var current_amount = killed_enemies.get(enemy_type, 0)
		_addEntry(Enemy.ENEMY_NAME_MAP[enemy_type], current_amount, total_amount)
		
func _addEntry(name: String, killed_amount: int, total_amount: int): 
	var newEntry = entry_template.instantiate() as KillCounterEntry
	newEntry.setAllInfos(name, killed_amount, total_amount)
	entries_holder.add_child(newEntry)
	background.visible = true

func _cleanEntries():
	for node in entries_holder.get_children():
		node.queue_free()
	background.visible = false
