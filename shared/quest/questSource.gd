extends Object
class_name QuestSource

var quest_name: String
var task_index: int

static func create(_quest_name: String, _task_index: int) -> QuestSource:
	var questSource = QuestSource.new()
	questSource.quest_name = _quest_name
	questSource.task_index = _task_index
	return questSource
