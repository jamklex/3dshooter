extends Object

class_name Condition

var method: String
var payload: Array

static func from(dict: Dictionary) -> Condition:
	var condition = Condition.new()
	condition.method = dict.get("method")
	condition.payload = dict.get("payload")
	return condition

static func create(method: String, payload: Array) -> Condition:
	var condition = Condition.new()
	condition.method = method
	condition.payload = payload
	return condition
