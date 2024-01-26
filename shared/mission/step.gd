class_name MissionStep

var id: String
var total: int
var count: int
var type: MissionStepType

enum MissionStepType {
	MONSTER, RESOURCE
}

static func from_json(json: Dictionary) -> MissionStep:
	return from(json.get("type"), json.get("id"), json.get("total"), json.get("count", 0))

static func from(_type: MissionStepType, _id: String, _total: int, _count: int = 0) -> MissionStep:
	var step = MissionStep.new()
	step.id = _id
	step.type = _type
	step.total = _total
	step.count = _count
	return step

func isDone() -> bool:
	return getCurrentCount() >= total

func getCurrentCount() -> int:
	if type == MissionStepType.RESOURCE:
		return WorldUtil.player.inventory.count(id)
	return min(count, total)

func addCount(amount: int):
	count += amount

func isEnemy(enemy_id: String) -> bool:
	return id == enemy_id

func toDict() -> Dictionary:
	if type == MissionStepType.MONSTER:
		return {
			"type": type,
			"id": id,
			"total": total,
			"count": count
		}
	return {
		"type": type,
		"id": id,
		"total": total
	}
