class_name Quest
extends Node

var title: String = ""
var tasks: Array = []
var active: bool = false
const scene = preload("res://shared/quest/scenes/quest.tscn")
@onready var layout = $panel/container

static func from(_tasks: Array, _active: bool) -> Quest:
	var quest = scene.instantiate() as Quest
	quest.active = _active
	var first = true
	for t in _tasks:
		var task = Task.from(t, quest.title) as Task
		if _active and first:
			task.set_active()
			first = false
		quest.add_task(task)
		if !quest.title:
			quest.title = task.title
	print("Quest " + quest.title + " loaded")
	return quest

func refresh_data():
	layout.get_node("name").text = title
	for task in tasks:
		if task.status == Task.Status.UNKNOWN and task.hide_if_unknown:
			continue
		layout.get_node("tasks").add_child(task)
		task.refresh_data()

func add_task(task: Task):
	tasks.push_back(task)

func set_succeed(task: Task):
	task.status = Task.Status.SUCCEEDED

func set_failed(task: Task):
	task.status = Task.Status.FAILED

func set_active(task: Task):
	task.status = Task.Status.ACTIVE

func get_active_task() -> Task:
	for task in tasks:
		if task.status == Task.Status.ACTIVE:
			return task
	return null
