class_name Pickable

extends RigidBody3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var item_type: Items.TYPE
@onready var mesh = $CollisionShape3D/MeshInstance3D
@export var highlight_seconds = 1.0 as float
@export var interact_distance_m = 2.0

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	InteractionHelper.add_onto(player, {"item_" + name:1})
	interactable = false
	self.queue_free()

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
