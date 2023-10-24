class_name Quest
extends Node

var path: String
var title: String = ""
var tasks: Array = []
var status: Status = Status.LOCKED
const scene = preload("res://shared/quest/scenes/quest.tscn")
@onready var layout = $container

static func from(_path: String, _tasks: Array, saved: Dictionary = {}) -> Quest:
	var quest = scene.instantiate() as Quest
	quest.path = _path
	var auto_unlock = quest.path.ends_with("tutorial/")
	if auto_unlock:
		quest.unlock()
		quest.set_status(Status.ACTIVE)
	var i = 0
	for t in _tasks:
		var task = Task.from(quest._on_event, t, i, quest.title) as Task
		if i == 0 and auto_unlock:
			task.set_active()
		task.status = saved.get(str(i), task.status)
		quest.add_task(task)
		if !quest.title:
			quest.title = task.title
		i += 1
	quest.status = saved.get("q", quest.status)
	return quest

enum Status {
	LOCKED, ACTIVE, SUCCEEDED, FAILED, SKIPPED
}

func save_dict() -> Dictionary:
	var save = {}
	for _t in tasks:
		save[str(_t.index)] = _t.status
	save["q"] = status
	return save

func _process(_delta):
	refresh_data()

func refresh_data():
	self.visible = status == Status.ACTIVE
	layout.get_node("name").text = title
	for _task in tasks:
		if _task.status <= Task.Status.UNKNOWN:
			continue
		if not _task.get_parent():
			var task_node = layout.get_node("tasks")
			task_node.add_child(_task)
			task_node.move_child(_task, 0)

func add_task(_task: Task):
	tasks.push_back(_task)

func set_succeeded(_task: Task):
	_task.set_succeeded()

func set_failed(_task: Task):
	_task.set_failed()

func set_active(_task: Task):
	_task.set_active()

func set_status(_status: Status):
	status = _status
	if status == Status.SUCCEEDED:
		for _t in tasks:
			set_succeeded(_t)

func get_active_task() -> Task:
	var active_tasks = tasks.filter(func(t): return t.status == Task.Status.ACTIVE)
	return active_tasks[0] if active_tasks.size() > 0 else null

func get_task(index: int) -> Task:
	return tasks[index] if tasks.size() > index else null

func unlock():
	if status >= Status.ACTIVE:
		return
	set_status(Status.ACTIVE)
	if get_active_task():
		return
	for _t in tasks:
		if _t.status < Task.Status.ACTIVE:
			_t.set_active()
			break

func _on_event(event_name: String, payload: Array = []):
	match event_name:
		"setActiveTask":
			set_active(tasks[int(payload[0])-1])
		"teleportToMissionMap":
			WorldUtil.teleportToMissionMap(payload)
		"succeedQuest":
			set_status(Status.SUCCEEDED)
		"failQuest":
			set_status(Status.FAILED)
		"unlockQuest":
			var target = QuestLoader.get_quest(payload[0]) as Quest
			target.unlock()
			QuestLoader.save_progress(target)
		"skipQuest":
			set_status(Status.SKIPPED)
		"succeedTask":
			set_succeeded(get_active_task())
		"failTask":
			set_failed(get_active_task())
		"unhideTasks":
			for _p in payload:
				var _t = get_task(int(_p)-1)
				if _t:
					_t.set_known()
		"giveRewards":
			for _r in get_active_task().rewards:
				InteractionHelper.add_drop_directly(WorldUtil.player, _r)
		"removeItem":
			var inv = WorldUtil.player.inventory as Inventory
			inv.remove(payload[0], payload[1])
		"save_progress":
			QuestLoader.save_progress(self)
		"unlock":
			for key in payload:
				WorldUtil.player.unlocks.push_back(key)
			WorldUtil.player.save()
		"giveSalvagerItems":
			var salvager_inventory = WorldUtil.player.store_inventory as Inventory
			var player_inventory = WorldUtil.player.inventory as Inventory
			salvager_inventory.moveAllItems(player_inventory)
		"setSalvagerFee":
			var salvager_fee = payload[0]/100 as float
			Trader.set_tax_value(salvager_fee)
		"unlockMissions":
			print("TODO: unlockMissions")
