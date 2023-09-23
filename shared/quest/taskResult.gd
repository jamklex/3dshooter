extends Object

class_name TaskResult

var conditions: Array
var actions: Array

static func from(dict: Dictionary) -> TaskResult:
	var result = TaskResult.new()
	for condition in dict.get("conditions", []):
		result.add_condition(Condition.from(condition))
	for action in dict.get("actions", []):
		result.add_action(Action.from(action))
	return result

static func create(conditions: String, actions: String) -> TaskResult:
	var result = TaskResult.new()
	result.conditions = conditions
	result.actions = actions
	return result

func add_condition(condition: Condition):
	conditions.push_back(condition)

func add_action(action: Action):
	actions.push_back(action)
