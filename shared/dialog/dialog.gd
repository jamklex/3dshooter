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
			
func _loadNextPart():
	if not "text" in dialog_data:
		if "action" in dialog_data:
			print("do action '", dialog_data["action"], "' with id '", dialog_data["id"], "'")
		_closeDialog()
		return
	_showText(dialog_data["text"])
	if "answers" in dialog_data:
		answers = dialog_data["answers"]
		_showAnswers(answers.keys())

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
#	if index == -1:   - for basic close on 0-Key
#		_closeDialog()
#		return
	if index < len(answers.keys()):
		print("index: " + str(index))
		dialog_data = answers[answers.keys()[index]]
		_loadNextPart()
			
func _getIndex(keycode):
#	keycode >= 48 - for basic close on 0-Key
	if keycode >= 49 and keycode <= 57:
		return keycode - 49
	return null
