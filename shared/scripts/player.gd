extends Node
class_name Player


var body: PlayerBody
var cam: Camera3D
var bodyStartPos: Vector3
var bodyLastPos: Vector3
var money:int = 0
var run_inventory: Inventory
var inventory: Inventory
var store_inventory: Inventory
var _savePath = "user://player.json" #"user://settings.json"

func _init():
	print("load player")
	if FileAccess.file_exists(_savePath):
		var file = FileAccess.open(_savePath, FileAccess.READ)
		var loadDict = JSON.parse_string(file.get_as_text()) as Dictionary
		run_inventory = Inventory.from(loadDict.get("runInv", {}))
		inventory = Inventory.from(loadDict.get("inv", {}))
		store_inventory = Inventory.from(loadDict.get("storeInv", {}))

func save():
	print("save player")
	var saveDict = {
		"runInv": run_inventory.to_dict(),
		"inv": inventory.to_dict(),
		"storeInv": store_inventory.to_dict()
	}
	var file = FileAccess.open(_savePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(saveDict, "\t"))

func teleport(sceneName:String, pos:Vector3=Vector3.ZERO):
	bodyStartPos = pos
	get_tree().change_scene_to_file("res://scenes/" + sceneName + "/_main.tscn")

func saveRunInventory():
	run_inventory.moveAllItems(inventory)
