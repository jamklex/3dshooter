extends Control


@onready var windowSizeSelector = $CenterContainer/VBoxContainer/WindowSize/windowSize as OptionButton
@onready var mouseSensSlider = $CenterContainer/VBoxContainer/MouseSens/mouseSens as HSlider
@onready var mouseSensSliderValue = $CenterContainer/VBoxContainer/MouseSens/mouseSensValue as Label
@onready var ambientSoundSlider = $CenterContainer/VBoxContainer/ambientSound/ambientSound as HSlider
@onready var ambientSoundSliderValue = $CenterContainer/VBoxContainer/ambientSound/ambientSoundValue as Label
@onready var soundEffectSlider = $CenterContainer/VBoxContainer/soundEffects/soundEffects as HSlider
@onready var soundEffectSliderValue = $CenterContainer/VBoxContainer/soundEffects/soundEffectsValue as Label


func _ready():
	windowSizeSelector.add_item("Fullscreen")
	for windowSize in UserSettings.WINDOW_SIZES:
		windowSizeSelector.add_item(String.num(windowSize.x, 0) + " x " + String.num(windowSize.y, 0))
		
func _on_draw():
	_show_settings()
	
func _show_settings():
	windowSizeSelector.selected = UserSettings.get_setting(UserSettings.KEY_WINDOW_SIZE_INDEX) + 1
	mouseSensSlider.value = UserSettings.get_setting(UserSettings.KEY_MOUSE_SENS)
	mouseSensSliderValue.text = str(UserSettings.get_setting(UserSettings.KEY_MOUSE_SENS))
	_set_sound_value(UserSettings.get_setting(UserSettings.AMBIENT_SOUND_LEVEL), ambientSoundSlider, ambientSoundSliderValue)
	_set_sound_value(UserSettings.get_setting(UserSettings.SOUND_EFFECTS_LEVEL), soundEffectSlider, soundEffectSliderValue)
	
func _set_sound_value(value:float, slider:HSlider, label:Label):
	value *= 100
	slider.value = value
	label.text = String.num(value, 0) + "%"
	

func _exit_btn():
	WorldUtil.quitGame()

func _apply_btn():
	UserSettings.set_setting(UserSettings.KEY_WINDOW_SIZE_INDEX, windowSizeSelector.selected-1)
	UserSettings.set_setting(UserSettings.KEY_MOUSE_SENS, mouseSensSlider.value)
	UserSettings.set_setting(UserSettings.AMBIENT_SOUND_LEVEL, ambientSoundSlider.value / 100)
	UserSettings.set_setting(UserSettings.SOUND_EFFECTS_LEVEL, soundEffectSlider.value / 100)
	UserSettings.apply_settings()

func _on_mouse_sens_value_changed(value):
	var sensAsText = str(value)
	if len(sensAsText) == 1:
		sensAsText = "0.00"
	elif len(sensAsText) == 3:
		sensAsText += "0"
	mouseSensSliderValue.text = sensAsText

func _on_ambient_sound_value_changed(value: float) -> void:
	ambientSoundSliderValue.text = String.num(value, 0) + "%" 

func _on_sound_effects_value_changed(value: float) -> void:
	soundEffectSliderValue.text = String.num(value, 0) + "%" 
