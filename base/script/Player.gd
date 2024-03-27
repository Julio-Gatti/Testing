class_name Player
extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $FPSCamera3D
@onready var ray: RayCast3D = $FPSCamera3D/RayCast3D

# Mouse pitch coefficient.
@export var m_pitch : float = 0.022
# Mouse yaw coefficient.
@export var m_yaw : float = 0.022
# Mouse sensitivity.
@export var sensitivity : float = 4.0

# Either an array of nodes or just parent to an inventory node...
var inventory : Inventory
var weapon : Node

func _enter_tree():
	print(get_class(), '._enter_tree')
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func attack():
	if weapon and weapon.has_method('fire'):
		weapon.fire(self)

func attack2():
	if weapon and weapon.has_method('fire2'):
		weapon.fire2(self)

func use():
	var interactable = ray.get_collider()
	print('use ', interactable)
	if interactable and interactable.has_method('interact'):
		# Smalltalk style messaging?
		interactable.interact(self)

func _input(event):
	# Handle mlook
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * m_yaw * sensitivity))
		camera.rotation.x = clamp(camera.rotation.x - deg_to_rad(event.relative.y * m_pitch * sensitivity), deg_to_rad(-89.9), deg_to_rad(89.9))
	else:
		if event.is_action_pressed('attack'):
			attack()
		if event.is_action_pressed('attack2'):
			attack2()
		if event.is_action_pressed('use'):
			use()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveleft", "moveright", "forward", "back")
	var wishdir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if wishdir:
		velocity.x = wishdir.x * speed
		velocity.z = wishdir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
