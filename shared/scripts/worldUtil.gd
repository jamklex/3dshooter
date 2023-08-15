extends Node

var player: Player
var playerCam: Camera3D
var currentDialog: Dialog
var dialogScene = preload("res://shared/dialog/dialog.tscn")

func createDialog(dialog_data_path:String) -> Dialog:
	if currentDialog:
		return null
	currentDialog = dialogScene.instantiate()
	currentDialog.loadDialogData(dialog_data_path)
	add_child(currentDialog)
	WorldUtil.player.isInConversation = true
	return currentDialog

func deleteDialog():
	remove_child(currentDialog)
	currentDialog = null
	WorldUtil.player.isInConversation = false
