extends Node3D
class_name NPC

var normalTransform: Transform3D

@export_file(".json") var dialog_data_path
@export var npc_name = "<NPC_NAME>"
@export var npc_id = "<NPC_ID>"
const POPUP_MESSAGE_FORMAT = "Talk to <NPC_NAME>"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_message: String

func _ready():
	normalTransform = transform

func can_interact():
	return true

func interact(_player: Player):
	startConversation()

func startConversation():
	lookToPlayer()
	WorldUtil.createDialog(npc_id, dialog_data_path).onExit.connect(resetPosition)

func lookToPlayer():
	if WorldUtil.player.body:
		transform = transform.looking_at(WorldUtil.player.body.position)
		
func resetPosition():
	transform = normalTransform

func popup_message():
	var message = default_popup_message
	if !message:
		message = POPUP_MESSAGE_FORMAT.replace("<NPC_NAME>", npc_name)
	return InteractionHelper.popup_message(message)
