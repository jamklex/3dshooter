extends PanelContainer

var current_tasks: Array[Task] = []
const quest_scene = preload("res://shared/ui/menu/quests/quest.tscn")
const task_scene = preload("res://shared/ui/menu/quests/task.tscn")

@onready var quest_list_active = $wrapper/quests/list/active
@onready var quest_list_complete = $wrapper/quests/list/complete
@onready var task_list = $wrapper/current_quest/tasks/list
@onready var task_desc = $wrapper/current_quest/current_task/desc
@onready var quest_lists = [quest_list_active, quest_list_complete]

func _ready():
	visibility_changed.connect(refresh)

func refresh():
	for _ql in quest_lists:
		_delete_nodes(_ql.get_children())
	for quest in QuestLoader.get_quests() as Array[Quest]:
		_add_quest(quest)

func _add_quest(quest: Quest):
	var scene = quest_scene.instantiate()
	scene.on_click.connect(_set_tasks)
	scene.parent = quest
	scene.get_node("Label").text = quest.title
	if quest.has_status(Quest.Status.ACTIVE):
		quest_list_active.add_child(scene)
		if task_list.get_children().is_empty():
			_set_tasks(quest)
	elif quest.is_complete():
		quest_list_complete.add_child(scene)

func _set_tasks(quest: Quest):
	_delete_nodes(task_list.get_children())
	task_desc.text = ""
	for task in quest.tasks:
		_add_task(task)
		if not task_desc.text.is_empty():
			continue
		_add_task_desc(task)

func _add_task(task: Task):
	var scene = task_scene.instantiate()
	scene.on_click.connect(_add_task_desc)
	scene.parent = task
	task_list.add_child(scene)

func _add_task_desc(task: Task):
	task_desc.text = PlaceholderRemover.sanitize(task.desc)

func _delete_nodes(list: Array[Node]):
	for n in list:
		n.free()

func _on_tab_pressed(index: int):
	var _index = 0
	for _ql in quest_lists:
		_ql.visible = _index == index
		_index += 1
