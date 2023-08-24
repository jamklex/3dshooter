class_name Clickable

extends CSGBox3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var action: Actions.TYPE
@export var highlight_seconds = 0.1 as float
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
	InteractionHelper.execute_action(action)
	await click_animation()

func highlight():
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	change_texture(glow_mat)

func remove_highlight():
	highlighted = false
	change_texture(default_mat)

func click_animation():
	print("clicking")
	return true

func change_texture(texture: Material):
	get_meshes()[1].surface_set_material(0, texture)
