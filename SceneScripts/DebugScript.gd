extends Control

var recorder
var recording
var output_spectrum
var recorder_spectrum

func _ready():

	recorder = AudioServer.get_bus_effect(1, 0)	
	output_spectrum = AudioServer.get_bus_effect_instance(0,0)
	recorder_spectrum = AudioServer.get_bus_effect_instance(1,1)


func _on_MainMenu_pressed():
	get_tree().change_scene("res://Scenes/MainScene.tscn")

func _on_RecordButton_pressed():
	if recorder.is_recording_active():
		recording = recorder.get_recording()
		$PlayButton.disabled = false
		recorder.set_recording_active(false)
		$RecordButton.text = "Record"
		$Status.text = ""
	else:
		$PlayButton.disabled = true
		recorder.set_recording_active(true)
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

# Draw Spectrum

const VU_COUNT = 800
const FREQ_MAX = 11050.0
const MIN_DB = 60
func draw_spectrum(spectrum, width=400, height=100, x=0, y=0):
	#warning-ignore:integer_division
	draw_rect(Rect2(x, y, width, height), Color.white)
	if is_instance_valid(spectrum):
		var w = width / VU_COUNT
		var prev_hz = 0
		for i in range(1, VU_COUNT+1):
			var hz = i * FREQ_MAX / VU_COUNT;
			var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
			var h = energy * height
			var tmp_x = x + w * (i-1)
			var tmp_y = y + height - h
			draw_rect(Rect2(tmp_x, tmp_y, w, h), Color.black)
			prev_hz = hz

func get_pitch(spectrum):
	if is_instance_valid(spectrum):
		var max_hz = 0
		var hz_val = 0
		var prev_hz = 0
		for i in range(50, 2000):
			var hz = i;
			var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			if magnitude > max_hz:
				max_hz = magnitude
				hz_val = i
			prev_hz = hz

		return hz_val

func _draw():
	draw_spectrum(output_spectrum, 800, 100, 0, 0)
	draw_spectrum(recorder_spectrum, 800, 100, 0, 110)
	$Pitch.text = str(get_pitch(recorder_spectrum))
	
	

func _process(_delta):
	update()
