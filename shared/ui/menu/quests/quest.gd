extends PanelContainer

signal on_click
var parent: Quest

var colors = {
	Quest.Status.LOCKED: Color.DIM_GRAY,
	Quest.Status.ACTIVE: Color("#762488"),
	Quest.Status.SUCCEEDED: Color.WEB_GREEN,
	Quest.Status.FAILED: Color.INDIAN_RED,
	Quest.Status.SKIPPED: Color.DIM_GRAY
}

func _process(_delta):
	$Label.add_theme_color_override("font_color", colors[parent.status])

func _on_click():
	on_click.emit(parent)
