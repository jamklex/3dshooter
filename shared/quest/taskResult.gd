extends Object

class_name TaskResult

var conditions: Array
var actions: Array

static func from(json: JSON) -> TaskResult:
	var result = TaskResult.new()
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
