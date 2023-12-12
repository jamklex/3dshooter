extends Object

class_name Condition

var source: QuestSource
var method: String
var payload: Array

static func from(_source: QuestSource, dict: Dictionary) -> Condition:
	var condition = Condition.new()
	condition.source = _source
	condition.method = dict.get("method")
	condition.payload = dict.get("payload")
	return condition

func check() -> bool:
	return Callable(self, method).bind(payload).call()

func hasItemCount(_payload: Array) -> bool:
	var main_inventory = WorldUtil.player.inventory as Inventory
	return main_inventory.check(_payload[0], _payload[1])

func hasKillCountMin(_payload: Array) -> bool:
	var minKills = _payload[0]
	return WorldUtil.player.kills >= minKills

func hasDummieCountMin(_payload: Array) -> bool:
	var minKills = _payload[0]
	return WorldUtil.player.dummy_kills >= minKills

func anyInSalvager(_payload: Array = []) -> bool:
	var salvager_inventory = WorldUtil.player.store_inventory as Inventory
	return !salvager_inventory.is_empty()

func hasMissionKills(_payload: Array) -> bool:
	var killAmount = _payload[0] as int
	return WorldUtil.player.mission_kills >= killAmount

func taskMissing(_payload: Array) -> bool:
	return not taskDone(_payload)

func taskDone(_payload: Array) -> bool:
	return QuestLoader.get_quest(source.quest_name).get_task(int(_payload[0])).is_done()
