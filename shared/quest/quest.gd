extends Object

class_name Quest

var name: String
var tasks: Array = []
var succeeded_tasks: Array = []
var failed_tasks: Array = []
var active_task: Task

static func from(json: JSON) -> Quest:
	var quest = Quest.new()
	return quest

func add_task(task: Task):
	tasks.push_back(task)

func add_succeed(task: Task):
	succeeded_tasks.push_back(task)

func add_failed(task: Task):
	failed_tasks.push_back(task)
