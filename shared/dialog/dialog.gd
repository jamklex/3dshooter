extends Control
class_name Dialog

var questionLabel: RichTextLabel
var answersContainer: VBoxContainer
var answerScene = preload("res://shared/dialog/answer.tscn")

var dialog_data
var dialogStarted:bool = false
signal onExit
var answers
var dialogTracker: Callable

static func new_instance(dialog_data_path: String, tracker: Callable):
	var dialog = load("res://shared/dialog/dialog.tscn").instantiate()
	dialog.dialogTracker = tracker
	dialog.loadDialogData(dialog_data_path)
	return dialog

func loadDialogData(dataPath:String):
	dialog_data = FileUtil.getContentAsJson(dataPath)
	dialogTracker.call(true)
	if questionLabel and not dialogStarted:
		_loadNextPart()

func _executeAction(action:String, payload:Array):
	if action == "teleportToMissionMap":
		WorldUtil.call(action, payload[0])
	elif action == "removeFromPlayerInventory" or action == "addToPlayerInventory" :
		WorldUtil.call(action, payload[0], payload[1])
		WorldUtil.player.body.refresh_inventory_output()
	elif action == "openLastLoot":
		WorldUtil.call(action, payload[0])
	elif action == "openSellLoot":
		WorldUtil.call(action, payload[0])
	else:
		print("dont know what to do with action '" + action + "'")

func _loadNextPart():
	if not "answer" in dialog_data:
		_closeDialog()
		if "action" in dialog_data:
			_executeAction(dialog_data["action"], dialog_data["payload"])
		elif "actions" in dialog_data:
			var actions = dialog_data["actions"]
			for i in range(len(actions)):
				_executeAction(actions[i]["action"], actions[i]["payload"])
		return
	_showText(dialog_data["answer"])
	if "options" in dialog_data:
		answers = _removeUnavailableAnswers(dialog_data["options"])
		_showAnswers(answers.keys())

func _removeUnavailableAnswers(dialogAnswers:Dictionary):
	var availableAnswers = {}
	for answerKey in dialogAnswers:
		var answerData = dialogAnswers[answerKey]
		if not "condition" in answerData:
			availableAnswers[answerKey] = answerData
			continue
		var condition = answerData["condition"]
		var action = condition["action"]
		var result = condition["result"]
		var payload = condition["payload"]
		if _isConditionFulfilled(action, result, payload):
			availableAnswers[answerKey] = answerData
	return availableAnswers

func _isConditionFulfilled(action:String, result:bool, payload:Array):
	if action == "checkPlayerInventory":
		return result == WorldUtil.call(action, payload[0], payload[1])
	elif action == "hasStoreInventoryItems":
		return result == WorldUtil.call(action)
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

func _showAnswers(answers):
	_clearAnswersContainer()
	for index in range(len(answers)):
		var key = str(index+1)
		var text = answers[index]
		var answer = answerScene.instantiate() as Answer
		answer.setText(key + " - " + text)
		answer.onClick.connect(func(): _handleSelection(index))
		answersContainer.add_child(answer)

func _showText(text:String):
	questionLabel.clear()
	questionLabel.add_text(text)

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
		dialog_data = answers[answers.keys()[index]]
		_loadNextPart()
			
func _getIndex(keycode):
	if keycode >= 49 and keycode <= 57:
		return keycode - 49
	return null
