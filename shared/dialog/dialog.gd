extends Control
class_name Dialog

var questionLabel: RichTextLabel
var answersContainer: VBoxContainer
var answerScene = preload("res://shared/dialog/answer.tscn")

var dialog_data: Dictionary
var dialogStarted:bool = false
signal onExit
var answers
var dialogTracker: Callable
var questSources: Dictionary = {}
var currentSource: QuestSource

static func new_instance(dialog_data_path: String, tracker: Callable):
	var dialog = load("res://shared/dialog/dialog.tscn").instantiate()
	dialog.dialogTracker = tracker
	dialog.set_dialog_data(dialog_data_path)
	return dialog

func set_dialog_data(data_path:String):
	dialog_data = FileUtil.getContentAsJson(data_path)

func load_dialog_data():
	dialogTracker.call(true)
	if questionLabel and not dialogStarted:
		_loadNextPart()

func _executeAction(action:String, payload:Array):
	if currentSource != null:
		var quest = QuestLoader.get_quest(currentSource.quest_name)
		var task = quest.get_task(currentSource.task_index)
		task.execute(action, payload)
	else:
		WorldUtil.call(action, payload)

func add_options(source: QuestSource, quote:String, dialog_tree:Dictionary):
	dialog_data["options"][quote] = dialog_tree
	questSources[quote] = source

func _loadNextPart():
	var hasAnswers = "answer" in dialog_data
	if not hasAnswers: # first exit dialog and then execute actions
		_closeDialog()
	if "method" in dialog_data:
		_executeAction(dialog_data["method"], dialog_data.get("payload", []))
	elif "actions" in dialog_data:
		var actions = dialog_data["actions"]
		for i in range(len(actions)):
			_executeAction(actions[i]["method"], actions[i].get("payload", []))
	if hasAnswers:
		_showText(dialog_data["answer"])
		if "options" in dialog_data:
			answers = _removeUnavailableAnswers(dialog_data["options"])
			_showOptions(answers)

func _removeUnavailableAnswers(dialogAnswers:Dictionary):
	var availableAnswers = {}
	for answerKey in dialogAnswers:
		var answerData = dialogAnswers[answerKey]
		if not "condition" in answerData:
			availableAnswers[answerKey] = answerData
			continue
		var condition = answerData["condition"]
		var action = condition["method"]
		var result = condition["result"]
		var payload = condition["payload"]
		if _isConditionFulfilled(action, result, payload):
			availableAnswers[answerKey] = answerData
	return availableAnswers

func _isConditionFulfilled(action:String, result:bool, payload:Array):
	if WorldUtil.has_method(action):
		return result == WorldUtil.call(action, payload)
	else:
		print("dont know what to do with action '" + action + "'... return false")
		return false

func _closeDialog():
	onExit.emit()
	dialogTracker.call(false)
	queue_free()

func _clearAnswersContainer():
	for child in answersContainer.get_children():
		child.queue_free()
		answersContainer.remove_child(child)

func _showOptions(_answers):
	_clearAnswersContainer()
	var answer_keys = _answers.keys()
	for index in range(len(answer_keys)):
		var key = str(index+1)
		var text = answer_keys[index]
		var answer = answerScene.instantiate() as Answer
		answer.setText(key + " - " + text)
		var opt_color = _answers.get(text, {}).get("color", null)
		if opt_color:
			answer.standardTextColor = Color(opt_color)
		answer.onClick.connect(func(): _handleSelection(index))
		answersContainer.add_child(answer)

func _showText(text:String):
	questionLabel.text = PlaceholderRemover.sanitize(text)

func _ready():
	questionLabel = $Panel/MarginContainer/VBoxContainer/question
	answersContainer = $Panel/MarginContainer/VBoxContainer/scrollContainer/answers
	if not dialogStarted:
		_loadNextPart()

func _input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		if not event.pressed or event.echo:
			return
		var index = _getIndex(event.keycode)
		if index != null:
			_handleSelection(index)

func _handleSelection(index):
	if index < len(answers.keys()):
		var quote = answers.keys()[index]
		var _source = questSources.get(quote)
		if _source != null:
			currentSource = _source
		dialog_data = answers[quote]
		_loadNextPart()

func _getIndex(keycode):
	if keycode >= 49 and keycode <= 57:
		return keycode - 49
	return null
