extends HBoxContainer

func _ready():
	QuestLoader.attach_quests($all)

func _process(delta):
	var current_quest = QuestLoader.get_quest("tutorial")
	QuestLoader.attach_tasks($current_quest/tasks, current_quest)
