class_name Quest
extends Node

var title: String = ""
var tasks: Array = []
var active: bool = false
var status: Status = Status.LOCKED
const scene = preload("res://shared/quest/scenes/quest.tscn")
@onready var layout = $panel/container

static func from(_tasks: Array, _active: bool) -> Quest:
	var quest = scene.instantiate() as Quest
	quest.active = _active
	var first = true
	var i = 0
	for t in _tasks:
		var task = Task.from(quest._on_event, t, i, quest.title) as Task
		i += 1
		if _active and first:
			task.set_active()
			first = false
		if task.is_active():
			quest.active = true
		quest.add_task(task)
		if !quest.title:
			quest.title = task.title
	print("Quest " + quest.title + " loaded")
	return quest

enum Status {
	LOCKED, UNLOCKED, ACTIVE, SUCCEEDED, FAILED
}

func _process(delta):
	refresh_data()

func refresh_data():
	layout.get_node("name").text = title
	for task in tasks:
		if task.status == Task.Status.UNKNOWN and task.hide_if_unknown:
			continue
		layout.get_node("tasks").add_child(task)
		task.refresh_data()

func add_task(task: Task):
	tasks.push_back(task)

func set_succeeded(task: Task):
	task.set_succeeded()

func set_failed(task: Task):
	task.set_failed()

func set_active(task: Task):
	task.set_active()

func set_status(_status: Status):
	status = _status

func get_active_task() -> Task:
	for task in tasks:
		if task.status == Task.Status.ACTIVE:
			return task
	return null

func get_task(index: int) -> Task:
	return tasks[index]

func unlock():
	if status < Status.UNLOCKED:
		status = Status.UNLOCKED

func _on_event(event_name: String, payload: Array = []):
	print("execute: " + event_name)
	match event_name:
		"succeedTask":
			set_succeeded(get_active_task())
		"setActiveTask":
			set_active(tasks[int(payload[0])-1])
		"teleportToMissionMap":
			WorldUtil.teleportToMissionMap(payload)
		"succeedQuest":
			set_status(Status.SUCCEEDED)
		"unlockQuest":
			QuestLoader.get_quest(payload[0]).unlock()
		"failTask":
			set_failed(get_active_task())
		"giveRewards":
			for _r in get_active_task().rewards:
				InteractionHelper.add_drop(WorldUtil.player, _r)
