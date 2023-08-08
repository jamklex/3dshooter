class_name InteractableChest

extends CSGBox3D

var interactable = true

func can_interact():
	return interactable

func interact(player: Player):
	player.run_inventory.append_array(random_items())
	if await open_animation():
		interactable = false

func highlight(ms: int):
	print("highlight object for " + str(ms) + "ms")

func open_animation():
	print("opening box")
	return true

func random_items():
	var items = [] as Array
	for i in range(randi_range(1,4)):
		items.append("item_" + str(i))
	return items
