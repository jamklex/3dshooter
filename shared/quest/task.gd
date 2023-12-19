class_name Task
extends Node

var title: String
var status: Status = Status.KNOWN
var desc: String
var short: String
var dialog: TaskDialog
var success_result: TaskResult
var fail_result: TaskResult
var rewards: Array
var quest_listener: Callable
var index: int

@onready var short_ui = $short as Control
const scene = preload("res://shared/quest/scenes/task.tscn")

static func from(_quest_listener: Callable, dict: Dictionary, _index: int, quest_name: String = "") -> Task:
	var task = scene.instantiate()
	task.index = _index
	task.quest_listener = _quest_listener
	if dict.get("active", false):
		task.set_active()
	task.title = dict.get("name", quest_name)
	var source = QuestSource.create(task.title if quest_name.is_empty() else quest_name, task.index)
	task.desc = dict.get("desc")
	task.short = dict.get("short")
	task.status = dict.get("status", Status.UNKNOWN)
	if dict.has("dialog"):
		task.dialog = TaskDialog.from(source, dict.get("dialog"), task.title)
	if dict.has("success"):
		task.success_result = TaskResult.from(source, _quest_listener, dict.get("success"))
	if dict.has("failure"):
		task.fail_result = TaskResult.from(source, _quest_listener, dict.get("failure"))
	var _rewards = dict.get("rewards", [])
	for _r in _rewards:
		for _key in _r.keys():
			task.rewards.push_back(DropItem.create_fix(_key, _r[_key]))
	return task

enum Status {
	UNKNOWN, KNOWN, ACTIVE, SUCCEEDED, FAILED, SKIPPED
}

func _process(_delta):
	refresh_data()
	if status != Status.ACTIVE:
		return
	if success_result and success_result.is_relevant():
		success_result.execute()
	elif fail_result and fail_result.is_relevant():
		fail_result.execute()

func set_known():
	status = Status.KNOWN

func set_active():
	status = Status.ACTIVE

func set_succeeded():
	status = Status.SUCCEEDED

func set_skipped():
	status = Status.SKIPPED

func set_failed():
	status = Status.FAILED

func is_active() -> bool:
	return status == Status.ACTIVE

func is_done() -> bool:
	return status > Status.ACTIVE

func refresh_data():
	for s in Status.values():
		var node_name = Status.keys()[s].to_lower()
		if not short_ui.has_node(node_name):
			continue
		var node = short_ui.get_node(node_name) as RichTextLabel
		if !node:
			continue
		node.visible = s == status
		if s > Status.UNKNOWN:
			node.text = short
		if s > Status.ACTIVE:
			node.text = "[s]" + node.text + "[/s]"

func execute(method: String, payload: Array):
	quest_listener.bind(method, payload).call()
	quest_listener.bind("save_progress", []).call()
