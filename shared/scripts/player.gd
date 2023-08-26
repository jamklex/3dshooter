extends Node
class_name Player


var body: PlayerBody
var cam: Camera3D
var bodyStartPos: Vector3
var bodyLastPos: Vector3
var money:int = 0
var run_inventory: Dictionary
var inventory: Dictionary
var isInConversation = false
var _savePath = "res://player.json" #"user://settings.json"

func _init():
	print("load player")
	if FileAccess.file_exists(_savePath):
		var file = FileAccess.open(_savePath, FileAccess.READ)
		var loadDict = JSON.parse_string(file.get_as_text())
		run_inventory = loadDict["runInv"]
		inventory = loadDict["inv"]
	
func save():
	print("save player")
	var saveDict = {
		"runInv": run_inventory,
		"inv": inventory
	}
	var file = FileAccess.open(_savePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(saveDict, "\t"))

func teleport(sceneName:String, pos:Vector3=Vector3.ZERO):
	bodyStartPos = pos
	get_tree().change_scene_to_file("res://scenes/" + sceneName + "/_main.tscn")

func saveRunInventory():
	for key in run_inventory.keys():
		if key in inventory:
			inventory[key] += run_inventory[key]
		else:
			inventory[key] = run_inventory[key]
	run_inventory.clear()
