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
