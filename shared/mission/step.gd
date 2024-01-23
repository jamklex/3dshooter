class_name MissionStep

var id: String
var total: int
var count: int
var type: MissionStepType

enum MissionStepType {
	MONSTER, RESOURCE
}

static func from_json(json: Dictionary) -> MissionStep:
	return from(json.get("type"), json.get("id"), json.get("total"), json.get("count"))

static func from(_type: MissionStepType, _id: String, _total: int, _count: int = 0) -> MissionStep:
	var step = MissionStep.new()
	step.id = _id
	step.type = _type
	step.total = _total
	step.count = _count
	return step

func isDone() -> bool:
	return count >= total

func toDict() -> Dictionary:
	return {
		"type": type,
		"id": id,
		"total": total,
		"count": count
	}
