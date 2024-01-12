extends Node

class_name Mission

var _name: String = "name"
var desc: String = "desc"
var rng: RandomNumberGenerator
var difficulty: Difficulty
var kills: Array[MissionStep] = []
var resources: Array[MissionStep] = []
var rewards: Array[InventoryItem] = []

enum Difficulty {
	EASY, MEDIUM, HARD
}

static func from(json_save: Dictionary) -> Mission:
	var mission = Mission.new()
	mission.name = json_save.get("name")
	mission.desc = json_save.get("desc")
	mission.difficulty = json_save.get("difficulty", Difficulty.EASY)
	mission.addRng()
	mission.rng.set_seed(int(json_save.get("seed", mission.rng.seed)))
	mission.rewards.append_array(toRewards(json_save.get("rewards", [])))
	mission.kills.append_array(toSteps(json_save.get("kills", [])))
	mission.resources.append_array(toSteps(json_save.get("resources", [])))
	return mission

static func toSteps(array: Array) -> Array:
	return array.map(func (e): return MissionStep.from_json(e))

static func toRewards(array: Array) -> Array:
	return array.map(func (e): return InventoryItem.from(e.keys()[0], e.values()[0]))

static func generate(rng: RandomNumberGenerator) -> Mission:
	var mission = Mission.new()
	mission.rng = rng
	mission.difficulty = rng.randi_range(0, Difficulty.values().max())
	mission.addKillCounter()
	mission.addResourceCounter()
	mission.addGoldReward(100, 100)
	return mission

func allDone() -> bool:
	var status: Array[MissionStep] = []
	status.push_back(kills)
	status.push_back(resources)
	return status.all(func (s: MissionStep): return s.isDone())

func addRng():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func addKillCounter():
	var modulo = 5
	var minKills = (difficulty + 1) * modulo
	var maxKills = minKills * 3
	if(difficulty >= Difficulty.EASY):
		addRandomKillCount("0", minKills*2, maxKills*2, modulo)
	if(difficulty >= Difficulty.MEDIUM):
		addRandomKillCount("1", minKills, maxKills, modulo)
	if(difficulty >= Difficulty.HARD):
		addRandomKillCount("2", minKills/2, maxKills/2, modulo)

func addRandomKillCount(monsterId: String, minKills: int, maxKills: int, modulo: int):
	var killCount = rng.randi_range(minKills, maxKills)
	killCount = max(killCount - (killCount % modulo), modulo)
	kills.push_back(MissionStep.from(monsterId, killCount))

func addResourceCounter():
	print("TODO: generate resource missions")

func addGoldReward(killCount: int, resourceCount: int):
	var minGold = killCount * 3.5
	var maxGold = (killCount + resourceCount) * 5.5
	var bonusPercent = difficulty / (difficulty + 2.0)
	var amount = rng.randi_range(minGold, maxGold) * (1 + bonusPercent)
	rewards.push_back(InventoryItem.from("0", amount))

func toDict() -> Dictionary:
	return {
		"name": _name,
		"desc": desc,
		"seed": str(rng.seed),
		"difficulty": difficulty,
		"kills": kills.map(func (m: MissionStep): return m.toDict()),
		"resources": resources.map(func (m: MissionStep): return m.toDict()),
		"rewards": rewards.map(func (i: InventoryItem): return i.toDict())
	}
