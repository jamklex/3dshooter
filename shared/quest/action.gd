extends Object

class_name Action

var method: String
var payload: Array

static func from(json: JSON) -> Action:
	var action = Action.new()
	return action

static func create(method: String, payload: Array) -> Action:
	var action = Action.new()
	action.method = method
	action.payload = payload
	return action
