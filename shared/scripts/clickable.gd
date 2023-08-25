class_name Clickable

extends CSGBox3D

var highlightTimer = Timer.new()
@onready var id = get_instance_id()
@export var interactable = true
@export var highlighted = false
@export var disable_on_interact = false
@export var action: Actions.TYPE
@export var highlight_seconds = 0.1 as float
@export var interact_distance_m = 2.0

func _ready():
	material = material.duplicate(true) # individual material
	if highlight_seconds > 0:
		highlightTimer.connect("timeout", Callable(self, "remove_highlight"), 0)
		highlightTimer.one_shot = true
		add_child(highlightTimer)

func can_interact():
	return interactable

func interact(player: Player):
	Actions.execute_action(action)
	await click_animation()
	if(disable_on_interact):
		interactable = false
		remove_highlight()

func highlight():
	if !interactable:
		return
	highlightTimer.wait_time = highlight_seconds
	highlightTimer.start()
	highlighted = true
	material.emission_enabled = true
	material.emission = material.albedo_color

func remove_highlight():
	highlighted = false
	material.emission_enabled = false

func click_animation():
	print("TODO: click animation")
	return true
