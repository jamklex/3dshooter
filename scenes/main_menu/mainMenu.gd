extends Control
class_name MainMenu

@onready var _settings_window = $settingsWindow as Panel
@onready var _settings = $settingsWindow/Settings as Settings

func _ready() -> void:
	_settings.set_on_apply(_on_settings_applied)
	_settings.hide_exit_button()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ship/_main.tscn")

func _on_options_pressed() -> void:
	_settings_window.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_applied() -> void:
	_settings_window.visible = false
