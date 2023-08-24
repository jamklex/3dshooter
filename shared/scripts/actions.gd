class_name Actions

enum TYPE {
	PRINT_ON,
	PRINT_OFF,
	TELEPORT_TO_BASE
}

static func execute_action(action: Actions.TYPE):
	match (action):
		Actions.TYPE.PRINT_ON:
			print("on")
		Actions.TYPE.PRINT_OFF:
			print("off")
		Actions.TYPE.TELEPORT_TO_BASE:
			print("teleport back")
		_:
			print("action " + str(action) + " is not implemented")
