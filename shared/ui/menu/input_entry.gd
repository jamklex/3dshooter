extends HBoxContainer
class_name InputEntry

@onready var actionLabel = $action
@onready var keyLabel = $key

var actionText = ""
var keyText = ""

func _ready() -> void:
	actionLabel.text = actionText
	keyLabel.text = keyText
