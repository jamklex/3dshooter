extends Node
class_name Player


var body: PlayerBody
var cam: Camera3D
var bodyStartPos: Vector3
var bodyLastPos: Vector3
var money:int = 0
var run_inventory: Dictionary
var inventory: Dictionary
var store_inventory: Dictionary
var _savePath = "user://player.json" #"user://settings.json"

func _init():
	print("load player")
	if FileAccess.file_exists(_savePath):
		var file = FileAccess.open(_savePath, FileAccess.READ)
		var loadDict = JSON.parse_string(file.get_as_text()) as Dictionary
		run_inventory = loadDict.get("runInv", {})
		inventory = loadDict.get("inv", {})
		store_inventory = loadDict.get("storeInv", {})
	
func save():
	print("save player")
	var saveDict = {
		"runInv": run_inventory,
		"inv": inventory,
		"storeInv": store_inventory
	}
	var file = FileAccess.open(_savePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(saveDict, "\t"))

func teleport(sceneName:String, pos:Vector3=Vector3.ZERO):
	bodyStartPos = pos
	get_tree().change_scene_to_file("res://scenes/" + sceneName + "/_main.tscn")

func saveRunInventory():
	move_all(run_inventory, inventory)

func move_all(from: Dictionary, to: Dictionary):
	for key in from.keys():
		if key in to:
			to[key] += from[key]
		else:
			to[key] = from[key]
	from.clear()
