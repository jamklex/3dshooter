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

func hasNotItemCount(_payload: Array) -> bool:
	var main_inventory = WorldUtil.player.inventory as Inventory
	return !main_inventory.check(_payload[0], _payload[1])

func hasItemCountTemp(_payload: Array) -> bool:
	var temp_inventory = WorldUtil.player.inventory as Inventory
	return temp_inventory.check(_payload[0], _payload[1])

func hasItemCountTotal(_payload: Array) -> bool:
	var main_inventory = WorldUtil.player.inventory as Inventory
	var storage = WorldUtil.player.storage as Inventory
	var itemId = _payload[0]
	var sum = main_inventory.count(itemId) + storage.count(itemId)
	return sum >= _payload[1]

func hasKillCountMin(_payload: Array) -> bool:
	var enemy_id = _payload[0]
	var minKills = _payload[1]
	var killCount = WorldUtil.player.kills.get(enemy_id, 0)
	return killCount >= minKills

func anyInSalvager(_payload: Array = []) -> bool:
	var salvager_inventory = WorldUtil.player.salvager as Inventory
	return !salvager_inventory.is_empty()

func hasMissionKills(_payload: Array) -> bool:
	var killAmount = _payload[0] as int
	return WorldUtil.player.mission_kills >= killAmount

func someTaskMissing(_payload: Array) -> bool:
	return _payload.any(func(t): return not taskDone(t))

func allTasksDone(_payload: Array) -> bool:
	return _payload.all(func(t): return taskDone(t))
	
func weaponEquipped(_payload: Array) -> bool:
	var equip_inv = WorldUtil.player.equipment as EquipmentInventory
	return equip_inv.count_item_type(GameItem.GameItemType.WEAPON) > 0
	
func noWeaponEquipped(_payload: Array):
	return not weaponEquipped(_payload)
	
func weaponWithAmmoEquipped(_payload: Array) -> bool:
	return WorldUtil.player.body.hasWeaponWithAmmo()

func noWeaponWithAmmoEquipped(_payload: Array) -> bool:
	return not weaponWithAmmoEquipped(_payload)

func taskDone(taskId: int) -> bool:
	return QuestLoader.get_quest(source.quest_name).get_task(taskId).is_done()
