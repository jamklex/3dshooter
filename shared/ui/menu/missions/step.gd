extends PanelContainer

var linked_step: MissionStep
var prefix: String
@onready var type = $wrapper/type
@onready var total = $wrapper/total
@onready var current = $wrapper/current

func add_link(link: MissionStep):
	linked_step = link

func _process(_delta):
	if (linked_step):
		if (isKillType()):
			type.set_text("Kill:")
		elif (isResourceType()):
			type.set_text(getIdName() + ":")
		current.set_text(str(min(linked_step.getCurrentCount(), linked_step.total)))
		total.set_text("/" + str(linked_step.total))

func isKillType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.MONSTER

func isResourceType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.RESOURCE

func getIdName() -> String:
	return ItemHelper.get_item(linked_step.id).name
