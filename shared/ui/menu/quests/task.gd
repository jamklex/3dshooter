extends PanelContainer

signal on_click
var parent: Task

func _on_click():
	on_click.emit(parent)
