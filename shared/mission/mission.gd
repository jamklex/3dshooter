extends Node

class_name Mission

var _name: String = "name"
var desc: String = "desc"
var rng: RandomNumberGenerator
var difficulty: Difficulty
var kills: Array[MissionStep] = []
var resources: Array[MissionStep] = []
var rewards: Array[InventoryItem] = []
var over: int
const missionTime_min: int = 45

enum Difficulty {
	EASY, MEDIUM, HARD
}

static func from(json_save: Dictionary) -> Mission:
	var mission = Mission.new()
	mission._name = json_save.get("name")
	mission.desc = json_save.get("desc")
	mission.difficulty = json_save.get("difficulty", Difficulty.EASY)
	mission.addRng()
	mission.rng.set_seed(int(json_save.get("seed", mission.rng.seed)))
	mission.rewards.append_array(toRewards(json_save.get("rewards", [])))
	mission.kills.append_array(toSteps(json_save.get("kills", [])))
	mission.resources.append_array(toSteps(json_save.get("resources", [])))
	if json_save.has("over"):
		mission.over = json_save.get("over")
	return mission

static func toSteps(array: Array) -> Array:
	return array.map(func (e): return MissionStep.from_json(e))

static func toRewards(array: Array) -> Array:
	return array.map(func (e): return InventoryItem.from(e.keys()[0], e.values()[0]))

static func generate(_rng: RandomNumberGenerator) -> Mission:
	var mission = Mission.new()
	mission.rng = _rng
	mission._name = SentenceGenerator.generate(_rng, true)
	mission.difficulty = _rng.randi_range(0, Difficulty.values().max())
	mission.generateKillCounter()
	mission.generateResourceCounter()
	mission.generateRewards()
	return mission

func allDone() -> bool:
	var status: Array[MissionStep] = []
	status.append_array(kills)
	status.append_array(resources)
	return status.all(func (s: MissionStep): return s.isDone())

func addRng():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func startMission():
	if !over:
		overIn(missionTime_min)
	save()

func overIn(mins: int):
	over = currentTime() + mins * 60

func isOver() -> bool:
	return currentTime() >= over

func currentTime() -> int:
	return int(Time.get_unix_time_from_system())

func save():
	WorldUtil.save_mission(self)

func generateKillCounter():
	var modulo = 5
	var minCount = (difficulty + 1) * modulo
	var maxCount = minCount * 3
	var tmp_options = []
	tmp_options.append_array(Enemy.ENEMY_TYPE.values())
	for n in difficulty + 1:
		if tmp_options.is_empty():
			break
		var id = tmp_options.pop_at(0)
		var total = rng.randi_range(minCount, maxCount)
		total = max(total - (total % modulo), modulo)
		kills.push_back(MissionStep.from(MissionStep.MissionStepType.MONSTER, str(id), total))

func generateResourceCounter():
	var rarities: Array[GameItem.Rarity] = []
	var minCount = 0
	var maxCount = 5
	match difficulty:
		Difficulty.EASY:
			rarities.append(GameItem.Rarity.COMMON)
			minCount = 5
			maxCount = 5
		Difficulty.MEDIUM:
			rarities.append_array([GameItem.Rarity.COMMON, GameItem.Rarity.UNCOMMON])
			minCount = 5
			maxCount = 10
		Difficulty.HARD:
			rarities.append(GameItem.Rarity.UNCOMMON)
			minCount = 10
			maxCount = 25
	var difficulty_counter = difficulty + 1
	var resource_options = ItemHelper.get_item_by_rarity(rarities) as Array[GameItem]
	for n in difficulty_counter:
		if resource_options.is_empty():
			break
		var item = resource_options.pop_at(rng.randi_range(0,resource_options.size()-1)) as GameItem
		var total = rng.randi_range(minCount, maxCount)
		resources.push_back(MissionStep.from(MissionStep.MissionStepType.RESOURCE, item.id, total))

func generateRewards():
	var gold = 0
	if difficulty > Difficulty.EASY:
		var reward_items = ItemHelper.get_item_by_rarity([GameItem.Rarity.UNCOMMON, GameItem.Rarity.RARE]).filter(func(item: GameItem): return !containsId(resources, item.id))
		var item = reward_items.pop_at(rng.randi_range(0,reward_items.size()-1)) as GameItem
		var amount = getAmount(rng, item)
		rewards.push_back(InventoryItem.from(item.id, amount))
		gold -= amount * getWorth(item)
	for r in resources:
		var item = ItemHelper.get_item_by_id(r.id)
		gold += r.total * getWorth(item)
	for k in kills:
		gold += k.total * getEnemyWorth(k.id)
	var minBonus = (difficulty + 1) * 15
	var maxBonus = minBonus * 3
	var bonus = rng.randi_range(minBonus, maxBonus)
	rewards.push_front(InventoryItem.from("0", gold + bonus))

func getAmount(rng: RandomNumberGenerator, item: GameItem):
	match item.rarity:
		GameItem.Rarity.COMMON:
			return rng.randi_range(5, 10)
		GameItem.Rarity.UNCOMMON:
			return rng.randi_range(2, 5)
		GameItem.Rarity.RARE:
			return 1
	return 0

func getWorth(item: GameItem):
	match item.rarity:
		GameItem.Rarity.COMMON:
			return 3.5
		GameItem.Rarity.UNCOMMON:
			return 5.7
		GameItem.Rarity.RARE:
			return 9.2
	return 0

func getEnemyWorth(id: String):
	match Enemy.ENEMY_TYPE.get(int(id)):
		Enemy.ENEMY_TYPE.WEAK_SQUISHY:
			return 5
		Enemy.ENEMY_TYPE.STRONG_SQUISHY:
			return 7
		Enemy.ENEMY_TYPE.WEAK_TANK:
			return 10
		Enemy.ENEMY_TYPE.STRONG_TANK:
			return 15
	return 0

func containsId(steps: Array[MissionStep], id: String):
	return steps.filter(func(step: MissionStep): return step.id == id).size() > 0

func getPunishment() -> Array[InventoryItem]:
	var punishment_ratio = 0.75
	var items: Array[InventoryItem] = []
	for r in rewards:
		if r.item.id != Inventory.GOLD_ITEM:
			continue
		items.push_back(InventoryItem.from(r.item.id, r.amount * punishment_ratio))
	return items

func can_pay_punishment() -> bool:
	for p in getPunishment():
		var resource_id = p.item.id
		var amount = p.amount
		if not WorldUtil.checkPlayerInventory([resource_id, amount]):
			return false
	return true

func addKillCounter(enemy_id: String, amount: int):
	for k in kills:
		if k.isEnemy(enemy_id):
			k.addCount(amount)
	save()

func getSeed() -> String:
	return str(rng.seed)

func toDict() -> Dictionary:
	return {
		"name": _name,
		"desc": desc,
		"seed": getSeed(),
		"difficulty": difficulty,
		"kills": kills.map(func (m: MissionStep): return m.toDict()),
		"resources": resources.map(func (m: MissionStep): return m.toDict()),
		"rewards": rewards.map(func (i: InventoryItem): return i.toDict()),
		"over": over
	}

func getTodoItems():
	var todo_item_steps = resources.filter(func (s: MissionStep): return !s.isDone())
	var todo_items_dict = {}
	for todo_item_step in todo_item_steps:
		todo_items_dict[todo_item_step.id] = todo_item_step.getRest()
	return todo_items_dict
	
func getTodoEnemies():
	var todo_enemy_steps = kills.filter(func (s: MissionStep): return !s.isDone())
	var todo_enemies_dict = {}
	for todo_enemy_step in todo_enemy_steps:
		todo_enemies_dict[todo_enemy_step.id] = todo_enemy_step.getRest()
	return todo_enemies_dict
