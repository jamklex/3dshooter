class_name InteractableItem

extends RigidBody3D

var interactable = true
var highlighted = false
var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@onready var mesh = $CollisionShape3D/MeshInstance3D
@onready var no_glow_texture = preload("res://assets/models/item/item.tres") as Material
@onready var glow_texture = preload("res://assets/models/item/item-glow.tres") as Material

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	WorldUtil.teleport("ship", Vector3(-1,-3,-12))
	InteractionHelper.add_onto(player, {"collectable_item_" + str(id):1})
	interactable = false
	self.queue_free()

func highlight(ms: int):
	highlightTimer.wait_time = ms/1000
	highlightTimer.start()
	highlighted = true
	change_texture(glow_texture)

func remove_highlight():
	highlighted = false
	change_texture(no_glow_texture)

func change_texture(texture: Material):
	mesh.set_surface_override_material(0, texture)
