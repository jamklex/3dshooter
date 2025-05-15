extends Control
class_name Settings

@onready var windowSizeSelector = $CenterContainer/VBoxContainer/WindowSize/windowSize as OptionButton
@onready var mouseSensSlider = $CenterContainer/VBoxContainer/MouseSens/mouseSens as HSlider
@onready var mouseSensSliderValue = $CenterContainer/VBoxContainer/MouseSens/mouseSensValue as Label
@onready var ambientSoundSlider = $CenterContainer/VBoxContainer/ambientSound/ambientSound as HSlider
@onready var ambientSoundSliderValue = $CenterContainer/VBoxContainer/ambientSound/ambientSoundValue as Label
@onready var soundEffectSlider = $CenterContainer/VBoxContainer/soundEffects/soundEffects as HSlider
@onready var soundEffectSliderValue = $CenterContainer/VBoxContainer/soundEffects/soundEffectsValue as Label
@onready var inputPanel = $CenterContainer/inputPanel as Panel
@onready var inputHolder = $CenterContainer/inputPanel/MarginContainer/VBoxContainer2/Inputs as VBoxContainer
@onready var exitBtn = $CenterContainer/VBoxContainer/exitBtn as Button
var inputEntryScene = preload("res://shared/ui/menu/input-entry.tscn")
var _on_apply: Callable

const ACTION_MAP = {
	"forward": "Move forwards",
	"back": "Move backwards",
	"left": "Move left",
	"right": "Move right",
	"jump": "Jump",
	"interact": "Talk / Interact / Use",
	"inventory": "Open inventory",
	"nextWeapon": "Next weapon",
	"prevWeapon": "Previous weapon",
	"putWeaponAway": "Put weapon away",
	"shoot": "Shoot",
	"aim": "Aim",
	"questlog": "Open questlog",
	"reload": "Reload weapon",
	"sprint": "Sprint",
	"moveSingleItem": "Move one item",
	"moveAllItems": "Move all items",
	"moveHalfItems": "Move half amount of items",
	"moveCustomAmountItems": "Move custom amount of items",
}

func hide_exit_button():
	exitBtn.visible = false

func set_on_apply(on_apply: Callable):
	_on_apply = on_apply

func _ready():
	windowSizeSelector.add_item("Fullscreen")
	for windowSize in UserSettings.WINDOW_SIZES:
		windowSizeSelector.add_item(String.num(windowSize.x, 0) + " x " + String.num(windowSize.y, 0))
	_load_keys()

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
	if _on_apply:
		_on_apply.call()

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

func _getInputMap():
	var inputMap = {}
	for action in InputMap.get_actions():
		if action.begins_with("ui_"):
			continue
		for event in InputMap.action_get_events(action):
			if not event is InputEventKey and not event is InputEventMouseButton:
				continue
			var actionText = ACTION_MAP.get(action)
			if not actionText:
				continue
			inputMap.set(actionText, event.as_text().replace("(Physical)", "").replace("+", " + "))
			break
	return inputMap

func _load_keys():
	for input in inputHolder.get_children():
		input.free()
	var inputMap = _getInputMap()
	for actionText in inputMap.keys():
		var keyText = inputMap.get(actionText)
		var inputEntry = inputEntryScene.instantiate() as InputEntry
		inputEntry.keyText = keyText
		inputEntry.actionText = actionText
		inputHolder.add_child(inputEntry)

func _on_show_settings_btn_pressed() -> void:
	inputPanel.visible = true

func _on_close_inputs_button_pressed() -> void:
	inputPanel.visible = false
