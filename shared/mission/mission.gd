extends Node

class_name Mission

var _name: String = "name"
var desc: String = "desc"
var rng: RandomNumberGenerator
var difficulty: Difficulty
var kills: Dictionary = {}
var resources: Dictionary = {}
var rewards: Dictionary = {}

enum Difficulty {
	EASY, MEDIUM, HARD
}

static func generate() -> Mission:
	var mission = Mission.new()
	mission.addRng()
	mission.difficulty = Difficulty.values().pick_random()
	var totalKills = mission.addKillCounter()
	var totalResources = mission.addResourceCounter()
	mission.addGoldReward(totalKills, totalResources)
	return mission

func addRng():
	rng = RandomNumberGenerator.new()
	rng.randomize()

func addKillCounter() -> int:
	var totalKills = 0
	var modulo = 5
	var minKills = (difficulty + 1) * modulo
	var maxKills = minKills * 3
	if(difficulty >= Difficulty.EASY):
		totalKills += addRandomKillCount("0", minKills*2, maxKills*2, modulo)
	if(difficulty >= Difficulty.MEDIUM):
		totalKills += addRandomKillCount("1", minKills, maxKills, modulo)
	if(difficulty >= Difficulty.HARD):
		totalKills += addRandomKillCount("2", minKills/2, maxKills/2, modulo)
	return totalKills

func addRandomKillCount(monsterId: String, minKills: int, maxKills: int, modulo: int) -> int:
	var killCount = rng.randi_range(minKills, maxKills)
	killCount = max(killCount - (killCount % modulo), modulo)
	kills[monsterId] = killCount
	return killCount

func addResourceCounter() -> int:
	print("TODO: generate resource missions")
	return 0

func addGoldReward(killCount: int, resourceCount: int):
	var minGold = killCount * 3.5
	var maxGold = (killCount + resourceCount) * 5.5
	var bonusPercent = difficulty / (difficulty + 2)
	rewards["0"] = rng.randi_range(minGold, maxGold) * (1 + bonusPercent)

func toDict() -> Dictionary:
	return {
		"name": _name,
		"desc": desc,
		"seed": str(rng.seed),
		"difficulty": difficulty,
		"kills": kills,
		"resources": resources,
		"rewards": rewards
	}
