extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	print("_ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _visible():
	pass
	#_load_inventory()

func _get_inventory() -> Inventory:
	var player = WorldUtil.player as Player
	var inventory:Inventory = null
	if player.inMissionMap:
		inventory = player.run_inventory
	else:
		inventory = player.inventory
	return inventory

#func _load_inventory():
	#var inventory = _get_inventory()
	#for item in inventory.items:
		#
