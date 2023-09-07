extends Control
class_name Answer

signal onClick
var textLabel: RichTextLabel
var text:String

func setText(newText:String):
	text = newText
	_setTextIntoLabel()

# Called when the node enters the scene tree for the first time.
func _ready():
	textLabel = $text
	_setTextIntoLabel()

func _on_pressed():
	onClick.emit()
	
func _setTextIntoLabel():
	if not textLabel or not text:
		return
	textLabel.text = text
	textLabel.fit_content = true

func _on_text_resized():
	if textLabel:
		custom_minimum_size.y = textLabel.size.y
