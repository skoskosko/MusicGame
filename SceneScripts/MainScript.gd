extends Node


func DebugScene():
	get_tree().change_scene("res://Scenes/DebugScene.tscn")

func _on_OpenDebug_pressed():
	DebugScene()
