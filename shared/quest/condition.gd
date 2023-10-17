extends Object

class_name Condition

var method: String
var payload: Array

static func from(dict: Dictionary) -> Condition:
	var condition = Condition.new()
	condition.method = dict.get("method")
	condition.payload = dict.get("payload")
	return condition

func check() -> bool:
	return Callable(self, method).bind(payload).call()

func hasItemCount(payload: Array) -> bool:
	var main_inventory = WorldUtil.player.inventory as Inventory
	return main_inventory.check(payload[0], payload[1])

func hasKillCountMin(payload: Array) -> bool:
	var minKills = payload[0]
	return true

func hasDummieCountMin(payload: Array) -> bool:
	var minKills = payload[0]
	return false

func anyInSalvager(payload: Array = []) -> bool:
	var salvager_inventory = WorldUtil.player.store_inventory as Inventory
	return !salvager_inventory.is_empty()

func hasQuestKills(payload: Array = []) -> bool:
	var questName = payload[0] as String
	var killAmount = payload[1] as int
	return false
