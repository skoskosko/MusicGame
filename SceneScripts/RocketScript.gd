extends Node2D

var recorder_spectrum : AudioEffectSpectrumAnalyzerInstance
var signal_processing = load("res://Scripts/SignalProcessing.gd")

# Animation Management
const TIME_ANIMATION_STEP = 0.03333
var time = 0

# Rocket movement management
const TIME_SOUND_CHECK = 100 # 100ms
const MOVE_STEP = 10
var wanted_height = 10

var last_move = 0
const recognition_length = 50
var start_of_sound = 0
var length_of_sound = 0
var last_sound = 0


var points = 0
var playing = true

## PLAYER MANAGEMENT
func calc_height(min_orig, max_orig, min_allowed, max_allowed, val):	
	return (max_allowed - min_allowed) * (val - min_orig) / (max_orig - min_orig) + min_allowed

func setRobotHeight():
	# up  -20 degrees
	# down 20 degrees

	var y = $Player.position.y
	# print("player pos:" + str(y))
	# print("wanted_height:" + str(wanted_height))
	if abs(y - wanted_height) > 10:
		if y < wanted_height: # go down
			pass
			$Player.global_position = $Player.global_position + Vector2(0, MOVE_STEP) 
			# $Player.position.y += MOVE_STEP
			$Player.rotation = 20
		else: # go up
			$Player.global_position = $Player.global_position - Vector2(0, MOVE_STEP) 
			# $Player.position.y -= MOVE_STEP
			$Player.rotation = -20
	else:
		$Player.global_position = Vector2($Player.global_position[0], wanted_height) 
		$Player.rotation = 0
	
func calcRobotHeight(min_hertz = 517, max_hertz=1034):
	# Fitted to to hertz of soprano recorder
	# 517 -> 590
	#
	# 1034 -> 10
	var start_time = OS.get_system_time_msecs()
	if start_time - last_move > TIME_SOUND_CHECK or length_of_sound != 0:
		var hertz = signal_processing.getFundFreq(recorder_spectrum)
		if hertz and min_hertz <= hertz and hertz <= max_hertz:
			var height = 600 - calc_height(min_hertz, max_hertz, 10, 590, hertz)

			if last_sound == hertz:
				length_of_sound = start_time - start_of_sound
				if length_of_sound > recognition_length:
					wanted_height = height
					last_move = start_time
			else:
				last_sound = hertz
				start_of_sound = start_time

## BACKGROUND MANAGER

## MANAGE STARS
var stars : Array = []
const STAR_COUNT = 20
const MIN_STAR_SPEED = 20
const MAX_STAR_SPEED = 80


func handleStars():
	for item in stars:
		var star : Sprite = item[0]
		var rigid : RigidBody2D = item[1]
		
		# print( rigid.global_transform.origin.x )
		if rigid.global_transform.origin.x < - (get_viewport().size[0] + 20):
			star.visible = false
			stars.erase(item)
			stars.append(initiate_star())
			# print("new star")

func initiate_star(rand_x = false):
	var star_rigid = RigidBody2D.new()
	star_rigid.mode = RigidBody2D.MODE_RIGID
	star_rigid.gravity_scale = 0
	star_rigid.linear_damp = 0
	var speed =  MIN_STAR_SPEED + randi() % int(MAX_STAR_SPEED-MIN_STAR_SPEED)
	star_rigid.linear_velocity.x = -speed
	var star = Sprite.new()
	var star_texture = load("res://Textures/Objects/Star-1.png")
	star.set_texture(star_texture)
	var x = get_viewport().size[0] + 20
	if rand_x:
		x = randi() % int(get_viewport().size[0])
	var y = randi() % int(get_viewport().size[1])
	star.global_position = Vector2(x, y)
	star_rigid.add_child(star, true)
	$StarHolder.add_child(star_rigid, true)
	return [star, star_rigid]

func initiate_stars():
	for i in range(STAR_COUNT):
		stars.append(initiate_star(true))

## Asteroid management

var max_asteroids = 1

func handleAsteroids():
	# var asteroid = $Meteorite.duplicate()
	# print(asteroid.global_position)
	#print(asteroid.name)
	# print(len($AsteroidHolder.get_children()))
	max_asteroids = int(points / 100)
	
	if len($AsteroidHolder.get_children()) < max_asteroids:
		var resource = load("res://Objects/Asteroid/Asteroid.tscn")
		var asteroid = resource.instance()
		asteroid.global_position = Vector2(int(get_viewport().size[0]), randi() % int(get_viewport().size[1]) ) 
		asteroid.linear_velocity.x = min (-100, -int((randi() % points) / 2) )
		$AsteroidHolder.add_child(asteroid, true)
		pass
	
	for asteroid in $AsteroidHolder.get_children ():
		if asteroid.global_position[0] < -40:
			asteroid.queue_free()


## GENERAL FUNCS



func animate():
	setRobotHeight()
	handleStars()
	handleAsteroids()
	points += 1
	$PointLabel.text= str(points)
	
func _ready():
	seed(OS.get_system_time_msecs())
	recorder_spectrum = AudioServer.get_bus_effect_instance(1,1)
	initiate_stars()

func _draw():
	calcRobotHeight()
	

func _process(delta):
	time += delta
	if time > TIME_ANIMATION_STEP:
		if playing:
			animate()
		time = 0
	update()


func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/MainScene.tscn")



func _on_Player_body_entered(body):
	playing = false
	get_tree().paused = true
	$PausePopup.show()


func _on_Main_Menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainScene.tscn")
