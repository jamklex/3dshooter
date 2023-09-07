class_name InteractionHelper

static func add_drop(player: Player, drop: DropItem):
	var inventory = player.run_inventory
	var drop_key = drop.id
	var drop_value = drop.get_amount()
	if inventory.has(drop_key):
		drop_value += inventory[drop_key]
	inventory[drop_key] = drop_value
	player.body.show_last_drop("found: " + drop.loot_message())
	player.body.refresh_inventory_output()

static func interact_distance(interactable, default_distance):
	var item_distance = interactable.get("interact_distance_m")
	if item_distance != null and item_distance > 0:
		return item_distance
	return default_distance

static func popup_message(message):
	var event = InputMap.action_get_events("interact")[0] as InputEvent
	var relevant_key = event.as_text().split(" (")[0]
	return message + " [" + relevant_key + "]"
