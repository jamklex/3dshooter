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
	var dialog = WorldUtil.createDialog(dialog_data_path)
	dialog.onExit.connect(stopConversation)
	
func stopConversation():
	resetPosition()

func lookToPlayer():
	if WorldUtil.player:
		transform = transform.looking_at(WorldUtil.player.position)
		
func resetPosition():
	transform = normalTransform
