class_name InteractionHelper

static func add_onto(player: Player, drops: Dictionary):
	var inventory = player.run_inventory
	for key in drops.keys():
		var value = drops[key]
		if inventory.has(key):
			value += inventory[key]
		inventory[key] = value
	player.body.show_last_drop("found: " + str(drops))
	player.body.refresh_inventory_output()
