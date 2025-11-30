class_name Player extends CharacterBody3D

@export var using_shovel := false

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var can_shovel := true
var quest_completed := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var dialogue_label = $CanvasLayer/HUD/DialogueLabel
@onready var blizzard_shader_rect = $CanvasLayer/BlizzardShaderRect

func _ready():
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_dialogue("Its winter again.\nI need to go turn on the generators.", 3)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if Globals.neither_steps:
				$SnowSteps.stop()
				$Footsteps.stop()
				if not $SquelchingFootsteps.playing:
					$SquelchingFootsteps.play()
			if Globals.snow_steps:
				if not $SnowSteps.playing:
					$SnowSteps.play()
				$Footsteps.stop()
				$SquelchingFootsteps.stop()
			else:
				if not $Footsteps.playing:
					$Footsteps.play()
				$SnowSteps.stop()
				$SquelchingFootsteps.stop()
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			$Footsteps.stop()
			$SnowSteps.stop()
			$SquelchingFootsteps.stop()
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		$Footsteps.stop()
		$SnowSteps.stop()
		$SquelchingFootsteps.stop()
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_pressed("interact"):
		if $Head/Camera3D/Shovel.visible and can_shovel:
			$AnimationPlayer.play("use_shovel")
	
	if using_shovel:
		for body in $Head/Camera3D/Shovel/Area3D.get_overlapping_bodies():
			if body.is_in_group("snow"):
				body.change_x_size(5)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func add_dialogue(text: String, wait_time: float, font_size: int = 24):
	dialogue_label.start_dialogue(text, wait_time, font_size)

func is_shovel_in_range(in_range: bool):
	$CanvasLayer/HUD/PickupShovelLabel.visible = in_range

func get_shovel():
	$CanvasLayer/HUD/PickupShovelLabel.visible = false
	$Head/Camera3D/Shovel.visible = true
	add_dialogue("(press E to use shovel)", 3)

func is_fusebox_in_range(in_range: bool):
	$CanvasLayer/HUD/FixFuseboxLabel.visible = in_range

func get_generator():
	quest_completed += 1
	if quest_completed == 2:
		add_dialogue("Finally I can sleep now...", 3, 50)
		var t = get_tree().create_timer(6)
		t.timeout.connect(func():
			get_tree().change_scene_to_file("res://scenes/end.tscn")
		)
	$CanvasLayer/HUD/QuestLabel.text = "Current Objective:\nTurn on generators (" + str(quest_completed) + "/2)"
