extends Node

const SAVE_PATH = "user://user_settings.json"
const WINDOW_SIZES = [
	Vector2(1280,720),
	Vector2(1366,768),
	Vector2(1600,900),
	Vector2(1920,1080)
]

const KEY_MOUSE_SENS = "mouse_sens"
const DEFAULT_MOUSE_SENS = 0.05
const KEY_WINDOW_SIZE_INDEX = "window_size_index"
const DEFAULT_WINDOW_SIZE_INDEX = -1  # => fullscreen

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
	
func _load():
	_raw_settings = FileUtil.getContentAsJson(SAVE_PATH)
	
func _save():
	FileUtil.saveJsonContent(SAVE_PATH, _raw_settings)
	
func apply_settings():
	_apply_video_settings()
	_apply_mouse_settings()
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
