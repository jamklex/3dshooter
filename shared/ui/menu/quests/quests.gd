extends PanelContainer

var current_tasks: Array[Task] = []
const quest_scene = preload("res://shared/ui/menu/quests/quest.tscn")
const task_scene = preload("res://shared/ui/menu/quests/task.tscn")

@onready var quest_list = $wrapper/quests/list
@onready var task_list = $wrapper/current_quest/tasks/list
@onready var task_desc = $wrapper/current_quest/current_task/desc

func _ready():
	visibility_changed.connect(refresh)

func _process(delta):
	pass

func _add_quest(quest: Quest):
	var scene = quest_scene.instantiate()
	scene.on_click.connect(_set_tasks)
	scene.parent = quest
	scene.get_node("Label").text = quest.title
	quest_list.add_child(scene)

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
	scene.get_node("Label").text = task.short
	task_list.add_child(scene)

func _add_task_desc(task: Task):
	print("refresh")
	task_desc.text = task.desc

func _delete_nodes(list: Array[Node]):
	for n in list:
		n.free()

func refresh():
	_delete_nodes(quest_list.get_children())
	for quest in QuestLoader.get_quests() as Array[Quest]:
		if not quest.has_status(Quest.Status.ACTIVE):
			continue
		_add_quest(quest)
		if task_list.get_child_count() > 0:
			continue
		_set_tasks(quest)
