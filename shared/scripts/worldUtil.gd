extends Node

var player: Player
var playerCam: Camera3D
var currentDialog: Dialog
var dialogScene = preload("res://shared/dialog/dialog.tscn")

func createDialog():
	if currentDialog:
		return
	currentDialog = dialogScene.instantiate()
	add_child(currentDialog)

func closeDialog():
	remove_child(currentDialog)
	currentDialog = null
