extends Node
class_name DeathScreen


func _on_respawn_btn_pressed():
	WorldUtil.respawn()


func _on_quit_btn_pressed():
	WorldUtil.quitGame()
