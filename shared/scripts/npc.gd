extends Node3D
class_name NPC

var normalTransform: Transform3D

@export_file(".json") var dialog_data_path

func _ready():
	normalTransform = transform

func can_interact():
	return true

func interact(player: Player):
	startConversation()

func startConversation():
	lookToPlayer()
	WorldUtil.createDialog(dialog_data_path).onExit.connect(resetPosition)

func lookToPlayer():
	if WorldUtil.player.body:
		transform = transform.looking_at(WorldUtil.player.body.position)
		
func resetPosition():
	transform = normalTransform
