class_name Pickable

extends RigidBody3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var item_type: Items.TYPE
@onready var mesh = $CollisionShape3D/MeshInstance3D
@export var highlight_seconds = 1.0 as float
@export var interact_distance_m = -1
const POPUP_MESSAGE_FORMAT = "Pick up <ITEM>"
@export_placeholder(POPUP_MESSAGE_FORMAT) var default_popup_messages: String
const FEEDBACK_MESSAGE_FORMAT = "Collected: <ITEM>"
@export_placeholder(FEEDBACK_MESSAGE_FORMAT) var default_feedback_messages: String

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	var item = DropItem.create_fix("item_" + name)
	InteractionHelper.add_drop(player, item)
	interactable = false
	var message = default_feedback_messages
	if !message:
		message = FEEDBACK_MESSAGE_FORMAT.replace("<ITEM>", item.loot_message())
	self.queue_free()
	return message

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
	var duplicate = mesh.get_surface_override_material(0).duplicate() # individual material
	mesh.set_surface_override_material(0, duplicate)
	return duplicate

func popup_message():
	var message = default_popup_messages
	if !message:
		message = POPUP_MESSAGE_FORMAT.replace("<ITEM>", str(item_type).to_pascal_case())
	return InteractionHelper.popup_message(message)
