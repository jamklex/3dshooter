class_name MissionStep

var type: String
var total: int
var current: int

static func from(type: String, total: int, current: int) -> MissionStep:
	var step = MissionStep.new()
	step.type = type
	step.total = total
	step.current = current
	return step

func isDone() -> bool:
	return current >= total
