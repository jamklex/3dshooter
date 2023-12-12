extends Control
class_name LoadingScreen

@onready var background = $background
@onready var loading_label = $background/loadingLabel
@onready var animation_player = $animationPlayer
var loading_text_updater = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	loading_text_updater.autostart = false
	loading_text_updater.one_shot = false
	loading_text_updater.timeout.connect(_update_loading_text)
	add_child(loading_text_updater)

func fade_in():
	animation_player.play("fade_in")
	loading_text_updater.start(0.2)
	await get_tree().create_timer(1).timeout

func fade_out():
	animation_player.play("fade_out")
	loading_text_updater.stop()
	await get_tree().create_timer(1).timeout
	
func _update_loading_text():
	if loading_label.text == "Loading...":
		loading_label.text = "Loading"
	else:
		loading_label.text += "."
