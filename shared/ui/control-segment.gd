@tool
class_name ControlSegment

extends Panel

@export var key: String
@export var img: Texture2D
@onready var key_space = $key as Label
@onready var img_space = $img as TextureRect

func _ready():
	key_space.text = InteractionHelper.control_key_for_event(key)
	img_space.texture = img
