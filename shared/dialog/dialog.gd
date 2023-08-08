extends Control
class_name Dialog

var diaPanel: Panel

func _ready():
	diaPanel = $Panel

func _input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		if not event.pressed or event.echo:
			return
		var index = getIndex(event.keycode)
		if index != null:
			print("index: " + str(index))
			
func getIndex(keycode):
	if keycode >= 49 and keycode <= 57:
		return keycode - 49
	return null
