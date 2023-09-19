extends Object

class_name Condition

var method: String
var payload: Array

static func from(json: JSON) -> Condition:
	var condition = Condition.new()
	return condition

static func create(method: String, payload: Array) -> Condition:
	var condition = Condition.new()
	condition.method = method
	condition.payload = payload
	return condition
