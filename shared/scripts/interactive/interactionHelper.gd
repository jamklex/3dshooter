class_name InteractionHelper

static func add_drop(player: Player, drop: DropItem):
	player.run_inventory.add(drop.id, drop.get_amount())
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
