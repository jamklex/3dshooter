class_name Pickable

extends RigidBody3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var item_type: Items.TYPE
@onready var mesh = $CollisionShape3D/MeshInstance3D
@export var highlight_seconds = 1.0 as float
@export_file("*.tres") var default_texture
@export_file("*.tres") var glow_texture
@onready var default_mat = load(default_texture) as Material
@onready var glow_mat = load(glow_texture) as Material

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	WorldUtil.teleport("ship", Vector3(-1,-3,-12)) # TODO: remove it, this was just for testing
	InteractionHelper.add_onto(player, {"item_" + str(id):1})
	interactable = false
	self.queue_free()

func highlight():
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	change_texture(glow_mat)

func remove_highlight():
	highlighted = false
	change_texture(default_mat)

func change_texture(texture: Material):
	mesh.set_surface_override_material(0, texture)
