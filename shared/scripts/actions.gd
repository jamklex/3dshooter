class_name Actions

enum TYPE {
	PRINT_ON,
	PRINT_OFF,
	TELEPORT_TO_BASE,
	STORE_LOOT
}

static func execute_action(action: Actions.TYPE):
	var player = WorldUtil.player as Player
	match (action):
		Actions.TYPE.PRINT_ON:
			print("on")
		Actions.TYPE.PRINT_OFF:
			print("off")
		Actions.TYPE.TELEPORT_TO_BASE:
			print("teleport back")
			player.saveRunInventory()
			WorldUtil.teleportToLowerShip()
		Actions.TYPE.STORE_LOOT:
			player.storeRunInventory()
		_:
			print("action " + str(action) + " is not implemented")
