extends Object

class_name TaskDialog

var npc: String
var quote: String # what the player says
var answer: String # what the npc says
var options: Array
var actions: Array

static func from(dict: Dictionary, quote: String, npc: String = "") -> TaskDialog:
	var dialog = TaskDialog.new()
	dialog.npc = dict.get("npc", npc)
	dialog.quote = quote
	dialog.answer = dict.get("answer")
	if dict.has("options"):
		var options = dict.get("options")
		for key in options.keys():
			dialog.add_option(TaskDialog.from(options.get(key), key, npc))
	if dict.has("actions"):
		for action in dict.get("actions"):
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
