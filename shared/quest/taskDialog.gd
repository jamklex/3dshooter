extends Object

class_name TaskDialog

var npc: String
var quote: String # what the player says
var answer: String # what the npc says
var options: Array
var actions: Array
var source: QuestSource
const DEFAULT_CLOSE_DIALOG = "End Conversation"

static func from(source: QuestSource, dict: Dictionary, quote: String, npc: String = "") -> TaskDialog:
	var dialog = TaskDialog.new()
	dialog.source = source
	dialog.npc = dict.get("npc", npc)
	dialog.quote = quote
	dialog.answer = dict.get("answer")
	var options = dict.get("options", {})
	for key in options.keys():
		dialog.add_option(TaskDialog.from(source, options.get(key), key, npc))
	for action in dict.get("actions", []):
		dialog.add_action(Action.from(action))
	return dialog

static func create(npc: String, quote: String, answer: String, options: Array, actions: Array) -> TaskDialog:
	var dialog = TaskDialog.new()
	dialog.npc = npc
	dialog.quote = quote
	dialog.answer = answer
	dialog.options = options
	dialog.actions = actions
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
			_options[_opt.quote] = _opt.as_dialog_options()
	if _options.is_empty():
		_options[DEFAULT_CLOSE_DIALOG] = {}
	return {
		"answer": answer,
		"actions": _actions,
		"options": _options
	}

func get_dialog_key() -> String:
	return quote
