extends PanelContainer

var linked_step: MissionStep
@onready var type = $wrapper/type
@onready var total = $wrapper/total

func add_link(link: MissionStep):
	linked_step = link

func _process(_delta):
	if (linked_step):
		if (isKillType()):
			type.set_text(getEnemyName() + ":")
		if (isResourceType()):
			type.set_text(getIdName() + ":")
		total.set_text(str(linked_step.total))

func isKillType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.MONSTER

func isResourceType() -> bool:
	return linked_step.type == MissionStep.MissionStepType.RESOURCE

func getIdName() -> String:
	return ItemHelper.get_item(linked_step.id).name

func getEnemyName() -> String:
	return Enemy.ENEMY_NAME_MAP.get(int(linked_step.id), "Unknown")
