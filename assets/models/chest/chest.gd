class_name InteractableChest

extends CSGBox3D

var interactable = true
var highlighted = false
var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@onready var no_glow_texture = preload("res://assets/models/chest/lock.tres") as Material
@onready var glow_texture = preload("res://assets/models/chest/lock-glow.tres") as Material

func _ready():
	highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
	highlightTimer.one_shot = true
	add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	InteractionHelper.add_onto(player, get_random_items())
	if await open_animation():
		interactable = false

func highlight(ms: int):
	highlightTimer.wait_time = ms/1000
	highlightTimer.start()
	highlighted = true
	change_texture(glow_texture)

func remove_highlight():
	highlighted = false
	change_texture(no_glow_texture)

func open_animation():
	print("opening box")
	return true

func get_random_items():
	var drops = {}
	drops["item_" + str(randi_range(1,9))] = randi_range(1,10)
	return drops

func change_texture(texture: Material):
	get_meshes()[1].surface_set_material(0, texture)
