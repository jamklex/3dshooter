extends SpringArm3D

@export var mouse_sensitivity := 0.05

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # locks mouse to screen

func _unhandled_input(event):
	if event is InputEventMouseMotion: # or controller right stick
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
