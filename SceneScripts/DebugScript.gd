extends Control

var effect
var recording

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	print(effect)


func _on_MainMenu_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_RecordButton_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$PlayButton.disabled = false
		effect.set_recording_active(false)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		effect.set_recording_active(true)
		$RecordButton.text = "Stop"
		$Status.text = "Recording..."



func _on_PlayButton_pressed():
	print(recording)
	print(recording.format)
	print(recording.mix_rate)
	print(recording.stereo)
	var data = recording.get_data()
#	print(data)
	print(data.size())
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()
