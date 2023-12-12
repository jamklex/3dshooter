extends Object

class_name Action

var method: String
var payload: Array

static func from(_source:QuestSource, dict: Dictionary) -> Action:
	var action = Action.new()
	action.method = dict.get("method")
	action.payload = dict.get("payload")
	action.payload.push_front(_source.task_index)
	return action

func as_dialog_action():
	return {
		"method": method,
		"payload": payload
	}
