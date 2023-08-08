class_name InteractableItem

extends RigidBody3D

var interactable = true

func can_interact():
	return interactable

func interact(player: Player):
	player.run_inventory.append(self)
	interactable = false
	self.queue_free()

func highlight(ms: int):
	print("highlight object for " + str(ms) + "ms")
