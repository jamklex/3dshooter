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

static func interact_distance(interactable, default_distance):
	var item_distance = interactable.get("interact_distance_m")
	if item_distance != null:
		return item_distance
	return default_distance
