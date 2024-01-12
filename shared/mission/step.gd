class_name MissionStep

var id: String
var total: int
var count: int

static func from_json(json: Dictionary) -> MissionStep:
	return from(json.get("id"), json.get("total"), json.get("count"))

static func from(_id: String, _total: int, _count: int = 0) -> MissionStep:
	var step = MissionStep.new()
	step.id = _id
	step.total = _total
	step.count = _count
	return step

func isDone() -> bool:
	return count >= total

func toDict() -> Dictionary:
	return {
		"id": id,
		"total": total,
		"count": count
	}
