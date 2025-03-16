extends Control

@onready var windowSizeSelector = $windowSize as OptionButton
@onready var mouseSensSlider = $mouseSens as HSlider
@onready var mouseSensLabel = $mouseSensLabel as Label

func _ready():
	windowSizeSelector.add_item("Fullscreen")
	for windowSize in UserSettings.WINDOW_SIZES:
		windowSizeSelector.add_item(String.num(windowSize.x, 0) + " x " + String.num(windowSize.y, 0))
		
func _on_draw():
	_show_settings()
	
func _show_settings():
	windowSizeSelector.selected = UserSettings.get_setting(UserSettings.KEY_WINDOW_SIZE_INDEX) + 1
	mouseSensSlider.value = UserSettings.get_setting(UserSettings.KEY_MOUSE_SENS)
	mouseSensLabel.text = str(UserSettings.get_setting(UserSettings.KEY_MOUSE_SENS))

func _exit_btn():
	WorldUtil.quitGame()

func _apply_btn():
	UserSettings.set_setting(UserSettings.KEY_WINDOW_SIZE_INDEX, windowSizeSelector.selected-1)
	UserSettings.set_setting(UserSettings.KEY_MOUSE_SENS, mouseSensSlider.value)
	UserSettings.apply_settings()

func _on_mouse_sens_value_changed(value):
	var sensAsText = str(value)
	if len(sensAsText) == 1:
		sensAsText = "0.00"
	elif len(sensAsText) == 3:
		sensAsText += "0"
	mouseSensLabel.text = sensAsText
