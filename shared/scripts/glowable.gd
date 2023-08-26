class_name Glowable

extends CSGBox3D

@onready var light = $light as OmniLight3D
@onready var light_energy = light.light_energy
@onready var light_indirect_energy = light.light_indirect_energy
@onready var light_volumetric_fog_energy = light.light_volumetric_fog_energy
@onready var emission_energy_multiplier = (material as StandardMaterial3D).emission_energy_multiplier
@export var active = true
@export var color = "c05239" as Color
@export_category("Flicker Effect")
@export var flicker_enabled = false
@export var flicker_interval_sec = [0.2,0.5,0.1,0.1,2,0.3]
@export var flicker_natural = true
var flicker_timer = Timer.new()
var flicker_pos = 0

func _ready():
	material = material.duplicate(true) # individual material
	if color:
		material.albedo_color = color
		light.light_color = color
	if !active:
		lights_off()
		return
	lights_on()
	if flicker_enabled:
		add_child(flicker_timer)
		flicker_timer.connect("timeout", Callable(self, "trigger_flicker"), 0)
		flicker_timer.start()

func lights_on():
	if color:
		material.emission = color
	material.emission_enabled = true
	light.visible = true
	light.light_energy = light_energy
	light.light_indirect_energy = light_indirect_energy
	light.light_volumetric_fog_energy = light_volumetric_fog_energy
	material.emission_energy_multiplier = emission_energy_multiplier

func lights_off():
	if flicker_natural:
		if randf() <= 0.3:
			light.light_energy = light_energy/3
			light.light_indirect_energy = light_indirect_energy/3
			light.light_volumetric_fog_energy = light_volumetric_fog_energy/3
			material.emission_energy_multiplier = emission_energy_multiplier/3
			return
	material.emission_enabled = false
	light.visible = false

func trigger_flicker():
	if light.visible:
		lights_off()
	else:
		lights_on()
	flicker_pos = (flicker_pos + 1) % flicker_interval_sec.size()
	var flicker_time = flicker_interval_sec[flicker_pos]
	if flicker_natural:
		flicker_time = flicker_time * randf_range(0,2)
	flicker_timer.wait_time = flicker_time
	flicker_timer.start()
