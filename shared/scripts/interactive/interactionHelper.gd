class_name InteractionHelper

static func add_drop(player: Player, drop: DropItem):
	player.run_inventory.add(drop.id, drop.get_amount())
	player.body.refresh_inventory_output()

static func add_drop_directly(player: Player, drop: DropItem):
	player.inventory.add(drop.id, drop.get_amount())
	player.body.refresh_inventory_output()
	player.body.add_reward_to_queue(drop)

static func interact_distance(interactable, default_distance):
	var item_distance = interactable.get("interact_distance_m")
	if item_distance != null and item_distance > 0:
		return item_distance
	return default_distance

static func popup_message(message: String) -> String:
	return message + " " + control_key_for_event("interact")

static func control_key_for_event(control_event: String) -> String:
	var action_events = InputMap.action_get_events(control_event)
	if action_events.is_empty():
		return ""
	var event = action_events[0] as InputEvent
	var relevant_key = event.as_text().split(" (")[0]
	return "[" + relevant_key + "]"
