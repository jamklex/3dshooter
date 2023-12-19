extends PanelContainer

signal on_click
var parent: Task
@onready var label = $Label

var colors = {
	Task.Status.UNKNOWN: Color.DIM_GRAY,
	Task.Status.KNOWN: Color.GRAY,
	Task.Status.ACTIVE: Color.WHITE,
	Task.Status.SUCCEEDED: Color.WEB_GREEN,
	Task.Status.FAILED: Color.INDIAN_RED,
	Task.Status.SKIPPED: Color.DIM_GRAY
}

func _process(_delta):
	label.add_theme_color_override("font_color", colors[parent.status])
	if parent.status >= Task.Status.KNOWN:
		label.text = parent.short
		label.disabled = false
	else:
		label.text = "???"
		label.disabled = true

func _on_click():
	on_click.emit(parent)
