extends Node
class_name Useable

@export var hover_text = "<Hover text here>"

func interact(_player: Player):
	print("Not implemented")
	
func can_interact():
	return true
	
func popup_message():
	return InteractionHelper.popup_message(hover_text)
