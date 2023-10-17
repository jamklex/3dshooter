extends Object

class_name PlaceholderRemover

static func sanitize(content:String) -> String:
	
	var mapping = {
		"SALVAGER_FEE_PERCENT": "???",
	}
	for action in InputMap.get_actions():
		mapping["ACTION_" + action] = InteractionHelper.control_key_for_event(action)
	for key in mapping.keys():
		content = content.replace("<" + key + ">", mapping[key])
	return content
