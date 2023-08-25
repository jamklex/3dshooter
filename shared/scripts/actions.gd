class_name Actions

enum TYPE {
	PRINT_ON,
	PRINT_OFF,
	TELEPORT_TO_BASE,
	STORE_LOOT
}

static func execute_action(action: Actions.TYPE):
	match (action):
		Actions.TYPE.PRINT_ON:
			print("on")
		Actions.TYPE.PRINT_OFF:
			print("off")
		Actions.TYPE.TELEPORT_TO_BASE:
			print("TODO: teleport back")
		Actions.TYPE.STORE_LOOT:
			print("TODO: store loot")
		_:
			print("action " + str(action) + " is not implemented")
