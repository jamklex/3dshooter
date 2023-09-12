extends Control
class_name Answer

signal onClick
var textLabel: RichTextLabel
@export var standardTextColor: Color
@export var highlightedTextColor: Color
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
	_setStandardTextColor()
	textLabel.text = text
	textLabel.fit_content = true

func _on_text_resized():
	if textLabel:
		custom_minimum_size.y = textLabel.size.y
		
func _setTextColor(newColor:Color):
	textLabel.add_theme_color_override("default_color", newColor)
		
func _setStandardTextColor():
	_setTextColor(standardTextColor)
	
func _setHoverTextColor():
	_setTextColor(highlightedTextColor)
