extends Node


func DebugScene():
	get_tree().change_scene("res://Scenes/DebugScene.tscn")

func RocketScene():
	get_tree().change_scene("res://Scenes/RocketScene.tscn")
	
func _on_OpenDebug_pressed():
	DebugScene()

func _on_OpenRocket_pressed():
	RocketScene()
