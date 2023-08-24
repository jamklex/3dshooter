class_name InteractionHelper

static func add_onto(player: Player, drops: Dictionary):
	var inventory = player.run_inventory
	for key in drops.keys():
		var value = drops[key]
		if inventory.has(key):
			value += inventory[key]
		inventory[key] = value
	player.show_last_drop("found: " + str(drops))
	player.refresh_inventory_output()
