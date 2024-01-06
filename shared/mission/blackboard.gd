extends Node3D

func _ready():
	var totalMissions = []
	for n in range(10):
		totalMissions.push_back(Mission.generate().toDict())
	print(JSON.stringify(totalMissions))

func _process(delta):
	pass
