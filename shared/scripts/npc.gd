extends Node3D

const MAX_TALK_DISTANCE = 3.0
var normalTransform: Transform3D


func _ready():
	normalTransform = transform

func _input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		if event.key_label == 69 and event.pressed and not event.echo:
			onInteractionButtonPressed()
		
func onInteractionButtonPressed():
	if playerIsInRange() and playerLookAtMe():
		startConversation()
		
func playerIsInRange():
	var playerPos = WorldUtil.player.position
	var distanceToPlayer = position.distance_to(playerPos)
	var isInRange = distanceToPlayer <= MAX_TALK_DISTANCE
	return isInRange
	
func playerLookAtMe():
	var space = get_world_3d().direct_space_state
	var camera = WorldUtil.playerCam
	var query = PhysicsRayQueryParameters3D.create(camera.global_position,
			camera.global_position - camera.global_transform.basis.z * 100)
	var lookAtCollider = space.intersect_ray(query).collider
	var lookAtMe = lookAtCollider == self
	return lookAtMe

func startConversation():
	lookToPlayer()
	_createTimer(3)
	WorldUtil.createDialog()
	WorldUtil.player.isInConversation = true
	await timer.timeout
	print("i dont wanna talk to him...")
	stopConversation()
	
func stopConversation():
	WorldUtil.closeDialog()
	WorldUtil.player.isInConversation = false
	resetPosition()

func lookToPlayer():
	if WorldUtil.player:
		transform = transform.looking_at(WorldUtil.player.position)
		
func resetPosition():
	transform = normalTransform
	
##### just for a little pause ###
var timer: Timer
func _createTimer(seconds):
	timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_INHERIT
	timer.wait_time = seconds
	self.add_child(timer)
	timer.start()
