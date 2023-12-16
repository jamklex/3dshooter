extends PanelContainer

var current_tasks: Array[Task] = []
const quest_scene = preload("res://shared/ui/menu/quests/quest.tscn")
const task_scene = preload("res://shared/ui/menu/quests/task.tscn")

@onready var quest_list = $wrapper/quests/list
@onready var task_list = $wrapper/current_quest/tasks/list
@onready var task_desc = $wrapper/current_quest/current_task/desc

func _ready():
	var is_added = false
	var quest_index = 0
	for quest in QuestLoader.get_quests() as Array[Quest]:
		if not quest.has_status(Quest.Status.ACTIVE):
			continue
		_add_quest(quest)
		quest_index += 1
		if task_list.get_child_count() > 0:
			continue
		_highlight(quest_list, quest_index-1)
		var task_index = 0
		for task in quest.tasks:
			_add_task(task)
			task_index += 1
			if not task_desc.text.is_empty():
				continue
			_highlight(task_list, task_index-1)
			_add_task_desc(task)

func _process(delta):
	pass

func _add_quest(quest: Quest):
	var scene = quest_scene.instantiate()
	scene.get_node("Label").text = quest.title
	quest_list.add_child(scene)

func _add_task(task: Task):
	var scene = task_scene.instantiate()
	scene.get_node("Label").text = task.short
	task_list.add_child(scene)

func _add_task_desc(task: Task):
	task_desc.text = task.desc

func _highlight(parent: Node, index: int):
	print("highlight element " + str(index) + " on object " + str(parent))
