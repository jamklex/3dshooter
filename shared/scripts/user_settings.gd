extends Node

const SAVE_PATH = "user://user_settings.json"
const WINDOW_SIZES = [
	Vector2(1280,720),
	Vector2(1366,768),
	Vector2(1600,900),
	Vector2(1920,1080),
	Vector2(2560,1440),
	Vector2(3840,2160)
]

const KEY_MOUSE_SENS = "mouse_sens"
const DEFAULT_MOUSE_SENS = 0.05
const KEY_WINDOW_SIZE_INDEX = "window_size_index"
const DEFAULT_WINDOW_SIZE_INDEX = -1  # => fullscreen
const AMBIENT_SOUND_LEVEL = "ambient_sound"
const SOUND_EFFECTS_LEVEL = "sound_effects"
const DEFAULT_SOUND_LEVEL = 0.8

var _raw_settings = {}

func _ready():
	get_window().unresizable = true
	_load()
	_fill_empty_settings()
	apply_settings()
	
func get_setting(key:String):
	if not key in _raw_settings:
		return null
	return _raw_settings[key]
	
func set_setting(key:String, value):
	_raw_settings[key] = value
	
func _fill_empty_settings():
	if not KEY_MOUSE_SENS in _raw_settings:
		set_setting(KEY_MOUSE_SENS, DEFAULT_MOUSE_SENS)
	if not KEY_WINDOW_SIZE_INDEX in _raw_settings:
		set_setting(KEY_WINDOW_SIZE_INDEX, DEFAULT_WINDOW_SIZE_INDEX)
	if not AMBIENT_SOUND_LEVEL in _raw_settings:
		set_setting(AMBIENT_SOUND_LEVEL, DEFAULT_SOUND_LEVEL)
	if not SOUND_EFFECTS_LEVEL in _raw_settings:
		set_setting(SOUND_EFFECTS_LEVEL, DEFAULT_SOUND_LEVEL)
	
func _load():
	_raw_settings = FileUtil.getContentAsJson(SAVE_PATH)
	
func _save():
	FileUtil.saveJsonContent(SAVE_PATH, _raw_settings)
	
func apply_settings():
	_apply_video_settings()
	_apply_mouse_settings()
	_apply_sound_settings()
	_save()
	
func _apply_video_settings():
	var window_size_index = get_setting(KEY_WINDOW_SIZE_INDEX)
	if window_size_index == -1:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = WINDOW_SIZES[window_size_index]
	
func _apply_mouse_settings():
	if WorldUtil.player and WorldUtil.player.body:
		WorldUtil.player.body.mouse_sensitivity = get_setting(KEY_MOUSE_SENS)
		
func _apply_sound_settings():
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Ambient"), get_setting(UserSettings.AMBIENT_SOUND_LEVEL))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sound"), get_setting(UserSettings.SOUND_EFFECTS_LEVEL))
	pass
