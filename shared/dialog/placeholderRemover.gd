extends Object

class_name PlaceholderRemover

static func sanitize(content:String) -> String:
	var color = Color.LIME_GREEN as Color
	var mapping = {
		"SALVAGER_FEE_PERCENT": Trader.get_tax_value_percent(),
	}
	for action in InputMap.get_actions():
		mapping["ACTION_" + action] = InteractionHelper.control_key_for_event(action)
	for key in mapping.keys():
		var color_coded_value = "[color=#" + color.to_html() + "]" + mapping[key] + "[/color]"
		content = content.replace("<" + key + ">", color_coded_value)
	return content
