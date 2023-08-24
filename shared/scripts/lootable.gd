class_name Lootable

extends CSGBox3D
var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var highlight_seconds = 1.0 as float

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
		remove_highlight()
		highlightTimer.stop()

func highlight():
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	highlighted = false
	material.emission_enabled = false

func open_animation():
	print("opening box")
	return true

func get_random_items():
	var drops = {}
	drops["item_" + str(randi_range(1,9))] = randi_range(1,10)
	return drops
