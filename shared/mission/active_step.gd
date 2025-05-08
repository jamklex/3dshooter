extends PanelContainer

var linked_step: MissionStep
var prefix: String
var color: Color
@onready var type = $wrapper/type as Label
@onready var total = $wrapper/total as Label
@onready var current = $wrapper/current as Label

func add_link(link: MissionStep):
	linked_step = link

func _process(_delta):
	if (linked_step):
		if (color):
			set_color(type, color)
			set_color(total, color)
			set_color(current, color)
		if (isKillType()):
			type.set_text(getEnemyName() + ":")
		elif (isResourceType()):
			type.set_text(getIdName() + ":")
		current.set_text(str(linked_step.getCurrentCount()))
		total.set_text("/" + str(linked_step.total))

func set_color(label: Label, color: Color):
	label.add_theme_color_override("font_color", color)

func isKillType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.MONSTER

func isResourceType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.RESOURCE

func getIdName() -> String:
	return ItemHelper.get_item_by_id(linked_step.id).name

func getEnemyName() -> String:
	return Enemy.ENEMY_NAME_MAP.get(int(linked_step.id), "Unknown")
