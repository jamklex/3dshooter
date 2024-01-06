extends VBoxContainer
class_name HealthBar

@onready var progressBar = $health as ProgressBar
@onready var progressBarText = $health/healthText as Label


func init(value, max_value):
	progressBar.max_value = max_value
	setHealth(value)
	
func setHealth(value):
	if value < 0:
		value = 0
	progressBar.value = value
	progressBarText.text = str(value) + " / " + str(progressBar.max_value)
