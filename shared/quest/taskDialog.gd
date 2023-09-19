extends Object

class_name TaskDialog

var npc: String
var quote: String # what the player says
var answer: String # what the npc says
var options: Array
var actions: Array

static func from(json: JSON) -> TaskDialog:
	var dialog = TaskDialog.new()
	return dialog

static func create(npc: String, quote: String, answer: String, options: Array, actions: Array) -> TaskDialog:
	var dialog = TaskDialog.new()
	dialog.quote = quote
	dialog.npc = npc
	dialog.answer = answer
	dialog.options = options
	dialog.actions = actions
	return dialog

func add_option(dialog: TaskDialog):
	dialog.npc = npc
	options.push_back(dialog)

func add_action(action: Action):
	actions.push_back(action)
