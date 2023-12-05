extends Object

class_name TaskDialog

var npc: String
var color: Color
var quote: String # what the player says
var answer: String # what the npc says
var options: Array
var actions: Array
var source: QuestSource
const DEFAULT_CLOSE_DIALOG = "End Conversation"

static func from(_source: QuestSource, dict: Dictionary, _quote: String, _npc: String = "", _color: Color = Color.AQUAMARINE) -> TaskDialog:
	var dialog = TaskDialog.new()
	dialog.source = _source
	dialog.npc = dict.get("npc", _npc)
	dialog.color = dict.get("color", _color)
	dialog.quote = _quote
	dialog.answer = dict.get("answer", "")
	var _options = dict.get("options", {})
	for key in _options.keys():
		dialog.add_option(TaskDialog.from(_source, _options.get(key), key, _npc, dialog.color))
	for action in dict.get("actions", []):
		dialog.add_action(Action.from(_source.task_index, action))
	return dialog

func add_option(dialog: TaskDialog):
	dialog.npc = npc
	options.push_back(dialog)

func add_action(action: Action):
	actions.push_back(action)

func as_dialog_options() -> Dictionary:
	var _actions = []
	for _act in actions:
		_actions.push_back(_act.as_dialog_action())
	var _options = {}
	if !options.is_empty():
		for _opt in options:
			_options[_opt.get_dialog_key()] = _opt.as_dialog_options()
	if _options.is_empty():
		_options[DEFAULT_CLOSE_DIALOG] = {}
	var result = {
		"color": color.to_html(),
		"answer": answer,
		"actions": _actions,
		"options": _options
	}
	if !answer:
		result.erase("answer")
		result.erase("options")
	return result

func get_dialog_key() -> String:
	return quote
