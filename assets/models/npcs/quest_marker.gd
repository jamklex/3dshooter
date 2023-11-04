extends Node3D

func _process(delta):
	if not visible:
		return
	rotate(Vector3(0,1,0), 1*delta)
