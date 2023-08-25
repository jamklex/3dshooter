extends Control
class_name Dialog

var textLabel: RichTextLabel

var dialog_data
var dialogStarted:bool = false
signal onExit
var answers


func loadDialogData(dataPath:String):
	var fileCont = _getFileContent(dataPath)
	dialog_data = JSON.parse_string(fileCont)
	if textLabel and not dialogStarted:
		_loadNextPart()
		
func _getFileContent(filePath:String):
	if not FileAccess.file_exists(filePath):
		return ""
	var file = FileAccess.open(filePath, FileAccess.READ)
	return file.get_as_text()
	
func _executeAction(actionData:Dictionary):
	var action = actionData["action"]
	if action == "teleportToMissionMap":
		WorldUtil.call(action, actionData["levelId"])
	elif action == "removeFromPlayerInventory" or action == "addToPlayerInventory" :
		WorldUtil.call(action, actionData["item"], actionData["amount"])
		WorldUtil.player.body.refresh_inventory_output()
	else:
		print("dont know what to do with action '" + action + "'")
			
func _loadNextPart():
	if not "text" in dialog_data:
		if "action" in dialog_data:
			_executeAction(dialog_data)
		elif "actions" in dialog_data:
			var actions = dialog_data["actions"]
			for i in range(len(actions)):
				_executeAction(actions[i])
		_closeDialog()
		return
	_showText(dialog_data["text"])
	if "answers" in dialog_data:
		answers = _removeUnavailableAnswers(dialog_data["answers"])
		_showAnswers(answers.keys())

func _removeUnavailableAnswers(dialogAnswers:Dictionary):
	var availableAnswers = {}
	for answerKey in dialogAnswers:
		var answerData = dialogAnswers[answerKey]
		if not "condition" in answerData:
			availableAnswers[answerKey] = answerData
			continue
		if _isConditionFulfilled(answerData["condition"]):
			availableAnswers[answerKey] = answerData
	return availableAnswers
	
func _isConditionFulfilled(condition:Dictionary):
	var action = condition["action"]
	var result = condition["result"]
	if action == "checkPlayerInventory":
		return result == WorldUtil.call(action, condition["item"], condition["amount"])
	else:
		print("dont know what to do with action '" + action + "'... return false")
		return false
	
func _closeDialog():
	onExit.emit()
	WorldUtil.deleteDialog()
	
func _showAnswers(answers):
	textLabel.add_text("\n\n")
	for index in range(len(answers)):
		var key = str(index+1)
		var answer = answers[index]
		textLabel.add_text(key + " - " + answer + "\n")

func _showText(text:String):
	textLabel.clear()
	textLabel.add_text(text)

func _ready():
	textLabel = $Panel/RichTextLabel
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
