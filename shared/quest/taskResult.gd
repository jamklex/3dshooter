extends Object

class_name TaskResult

var conditions: Array[Condition] = []
var actions: Array[Action] = []
var quest_listener: Callable

static func from(_source: QuestSource, _quest_listener: Callable, dict: Dictionary) -> TaskResult:
	var result = TaskResult.new()
	result.quest_listener = _quest_listener
	for condition in dict.get("conditions", []):
		result.add_condition(Condition.from(_source, condition))
	for action in dict.get("actions", []):
		result.add_action(Action.from(_source, action))
	return result

static func create(_conditions: String, _actions: String) -> TaskResult:
	var result = TaskResult.new()
	result.conditions = _conditions
	result.actions = _actions
	return result

func add_condition(condition: Condition):
	conditions.push_back(condition)

func add_action(action: Action):
	actions.push_back(action)

func is_relevant() -> bool:
	return conditions.all(func(c): return c.check())

func execute():
	for _act in actions:
		quest_listener.bind(_act.method, _act.payload).call()
