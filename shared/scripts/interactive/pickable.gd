@tool
class_name Pickable

extends RigidBody3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var item_id = "4"
@onready var item = ItemHelper.get_item_by_id(item_id)
@onready var mesh = $CollisionShape3D/MeshInstance3D
@export var highlight_seconds = 1.0 as float
@export var interact_distance_m = -1
const POPUP_MESSAGE_FORMAT = "Pick up <ITEM>"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_message: String
const FEEDBACK_MESSAGE_FORMAT = "Collected: <ITEM>"
@export_placeholder(FEEDBACK_MESSAGE_FORMAT) var default_feedback_messages: String
var audioPlayer: AudioStreamPlayer3D

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)
	audioPlayer = AudioStreamPlayer3D.new()
	add_child(audioPlayer)

func can_interact():
	return interactable

func interact(player: Player):
	var loot = DropItem.create_fix(item_id) as DropItem
	InteractionHelper.add_drop(player, loot)
	interactable = false
	var message = default_feedback_messages
	if !message:
		var interact_feedback = loot.pretty_name()
		var amount = loot.get_amount()
		if amount > 1:
			interact_feedback += " x" + str(amount)
		message = FEEDBACK_MESSAGE_FORMAT.replace("<ITEM>", interact_feedback)
	self.queue_free()
	SoundUtil.playAtRandomPitch(audioPlayer, SoundUtil.SoundName.LOOT_PICKUP)
	return message

func setVisible(state: bool):
	visible = state

func highlight():
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	var material = get_material()
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	highlighted = false
	get_material().emission_enabled = false

func get_material():
	var _duplicate = mesh.get_surface_override_material(0).duplicate() # individual material
	mesh.set_surface_override_material(0, _duplicate)
	return _duplicate

func popup_message():
	var message = default_popup_message
	if !message:
		message = POPUP_MESSAGE_FORMAT.replace("<ITEM>", item.name)
	return InteractionHelper.popup_message(message)
