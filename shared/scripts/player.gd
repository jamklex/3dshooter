extends Node3D
class_name Player

var body: PlayerBody
var bodyStartPos: Vector3
var bodyLastPos: Vector3
var money:int = 0
var taxes:float
var unlocks:Array
var storage: Inventory
var inventory: Inventory
var salvager: Inventory
var equipment: EquipmentInventory
var _savePath = "user://player.json" #"user://settings.json"
var inMissionMap = false
var kills: Dictionary
var mission_kills = 0

func _init():
	var loadDict = {}
	if FileAccess.file_exists(_savePath):
		var file = FileAccess.open(_savePath, FileAccess.READ)
		var fileText = file.get_as_text()
		if fileText and len(fileText) > 0:
			loadDict = JSON.parse_string(file.get_as_text()) as Dictionary
	storage = Inventory.from(loadDict.get("storage", {}))
	inventory = Inventory.from(loadDict.get("inventory", {}))
	salvager = Inventory.from(loadDict.get("salvager", {}))
	equipment = EquipmentInventory.from(loadDict.get("equipment", {}))
	kills = loadDict.get("kills", {})
	taxes = loadDict.get("taxes", 100)
	unlocks = loadDict.get("unlocks", [])

func save():
	var saveDict = {
		"storage": storage.to_dict(),
		"inventory": inventory.to_dict(),
		"salvager": salvager.to_dict(),
		"equipment": equipment.to_dict(),
		"kills": kills,
		"taxes": taxes,
		"unlocks": unlocks
	}
	FileUtil.saveJsonContent(_savePath, saveDict)

func teleport(sceneName:String, pos:Vector3=Vector3.ZERO):
	bodyStartPos = pos
	get_tree().change_scene_to_file("res://scenes/" + sceneName + "/_main.tscn")

func setInMission(newInMissionMap:bool):
	inMissionMap = newInMissionMap
	if inMissionMap:
		mission_kills = 0

func addKillCounter(enemy_id: String, amount: int):
	if inMissionMap:
		mission_kills += amount
	kills[enemy_id] = kills.get(enemy_id, 0) + amount

func clearMissionInventories():
	body._shooter.removeBullets()
	inventory.clear()
	equipment.clear()
	save()
