extends Node
class_name Player


var body: PlayerBody
var bodyStartPos: Vector3
var bodyLastPos: Vector3
var money:int = 0
var taxes:float
var unlocks:Array
var run_inventory: Inventory
var inventory: Inventory
var store_inventory: Inventory
var equip_inventory: EquipmentInventory
var _savePath = "user://player.json" #"user://settings.json"
var inMissionMap = false
var kills = 0
var dummy_kills = 0
var mission_kills = 0

func _init():
	print("load player")
	var loadDict = {}
	if FileAccess.file_exists(_savePath):
		var file = FileAccess.open(_savePath, FileAccess.READ)
		var fileText = file.get_as_text()
		if fileText and len(fileText) > 0:
			loadDict = JSON.parse_string(file.get_as_text()) as Dictionary
	run_inventory = Inventory.from(loadDict.get("runInv", {}))
	inventory = Inventory.from(loadDict.get("inv", {}))
	store_inventory = Inventory.from(loadDict.get("storeInv", {}))
	equip_inventory = EquipmentInventory.from(loadDict.get("equipInv", {}))
	kills = loadDict.get("kills", 0)
	dummy_kills = loadDict.get("dummy_kills", 0)
	taxes = loadDict.get("taxes", 100)
	unlocks = loadDict.get("unlocks", [])

func save():
	print("save player")
	if body and body._shooter:
		body._shooter.putBulletsToInventory()
	var saveDict = {
		"runInv": run_inventory.to_dict(),
		"inv": inventory.to_dict(),
		"storeInv": store_inventory.to_dict(),
		"equipInv": equip_inventory.to_dict(),
		"kills": kills,
		"dummy_kills": dummy_kills,
		"taxes": taxes,
		"unlocks": unlocks
	}
	FileUtil.saveJsonContent(_savePath, saveDict)

func teleport(sceneName:String, pos:Vector3=Vector3.ZERO):
	bodyStartPos = pos
	get_tree().change_scene_to_file("res://scenes/" + sceneName + "/_main.tscn")

func setInMission(newInMissionMap:bool):
	inMissionMap = newInMissionMap
	#if body:
		#body._shooter.setUseRealMunition(inMissionMap)
	if inMissionMap:
		mission_kills = 0
	else:
		print("killed ", mission_kills, " in a mission")

func saveRunInventory():
	run_inventory.moveAllItems(inventory)
	
func onShootableKilled(shootable:Shootable):
	var killedDummy = (shootable.get_parent() as Dummy) != null
	if killedDummy:
		dummy_kills += 1
	else:
		kills += 1
	if inMissionMap:
		mission_kills += 1
