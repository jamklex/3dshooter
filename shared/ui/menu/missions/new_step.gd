extends PanelContainer

var linked_step: MissionStep
var prefix: String
@onready var type = $wrapper/type
@onready var total = $wrapper/total

func add_link(prefix_text: String, link: MissionStep):
	linked_step = link
	prefix = prefix_text

func _process(_delta):
	if (linked_step):
		type.set_text(prefix + linked_step.id + ":")
		total.set_text(str(linked_step.total))
