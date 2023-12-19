extends PanelContainer

signal on_click
var parent: Quest

func _on_click():
	on_click.emit(parent)
