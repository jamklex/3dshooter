@tool
extends Node3D
class_name NPC

var normalTransform: Transform3D

@export_file(".json") var dialog_data_path
@export var npc_name = "<NPC_NAME>"
@export var npc_id = "<NPC_ID>"
const POPUP_MESSAGE_FORMAT = "Talk to <NPC_NAME>"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_message: String
@onready var questMarker: Node3D = $QuestMarker
@onready var skin: MeshInstance3D = $Skin
@onready var eyes: MeshInstance3D = $Skin/Front
@export var skin_material: Material
@export var eyes_material: Material
var show_marker = false

func _ready():
	if skin_material:
		skin.material_override = skin_material
	if eyes_material:
		eyes.material_override = eyes_material
	normalTransform = transform

func _process(_delta):
	questMarker.visible = show_marker

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

func show_quest_marker():
		show_marker = true

func hide_quest_marker():
		show_marker = false
