extends Object

class_name PlaceholderRemover

static func sanitize(content: String) -> String:
	var color = Color.LIME_GREEN as Color
	var mapping = {
		"SALVAGER_FEE_PERCENT": Trader.get_tax_value_percent(),
	}
	for action in InputMap.get_actions():
		mapping["ACTION_" + action] = InteractionHelper.control_key_for_event(action)
	for key in mapping.keys():
		var color_coded_value = "[color=#" + color.to_html() + "]" + mapping[key] + "[/color]"
		content = content.replace("<" + key + ">", color_coded_value)
	content = replace_highlights(content, "highlight", color)
	return content

static func replace_highlights(content: String, key: String, color: Color) -> String:
	var regex = RegEx.create_from_string("\\["+key+"\\][^\\[]*\\[\\/"+key+"\\]")
	var callback := func(text:String) -> String: return text.replace("/" + key, "/color").replace(key, "color=#" + color.to_html())
	var offset := 0
	for regex_match in regex.search_all(content):
		var start := regex_match.get_start()
		var end := regex_match.get_end()
		var length := end - start
		var text := content.substr(start + offset, length)
		var replacement := str(callback.call(text))
		content = (
			content.substr(0, start + offset)
			 + replacement
			 + content.substr(end + offset)
		)
		offset += replacement.length() - text.length()
	return content
