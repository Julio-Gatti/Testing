class_name Player
extends CharacterBody3D

# Maximum movement speed.
@export var speed = 5.0
@export var jump_velocity = 4.5

# Get the gravity from the project settings to be synced with `RigidBody` nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $FPSCamera3D
@onready var ray: RayCast3D = $FPSCamera3D/RayCast3D

# Quake mouse pitch coefficient.
@export var m_pitch : float = 0.022
# Quake mouse yaw coefficient.
@export var m_yaw : float = 0.022
# Quake mouse sensitivity.
@export var sensitivity : float = 4.0

# Either an array of nodes or just parent to an inventory node...
var inventory : Inventory
var weapon : Weapon

# Called upon being added to the `SceneTree`, so essentially upon spawning.
func _enter_tree():
	print(get_class(), '._enter_tree')
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	# TODO Quake "think"
	pass

# Quake +attack
func attack():
	if weapon and weapon.has_method('fire'):
		# Smalltalk style messaging?
		# In a Simula based language like C++ this wouldn't even compile.
		weapon.fire(self)

func attack2():
	if weapon and weapon.has_method('fire2'):
		weapon.fire2(self)

func use():
	var interactable = ray.get_collider()
	print('use ', interactable)
	if interactable and interactable.has_method('interact'):
		interactable.interact(self)

# Quake client input
# https://github.com/id-Software/Quake-III-Arena/blob/master/code/client/cl_input.c
func _input(event):
	# Handle mlook
	# TODO keyboard look
	if event is InputEventMouseMotion:
		# TODO ugly
		rotate_y(deg_to_rad(-event.relative.x * m_yaw * sensitivity))
		camera.rotation.x = clamp(camera.rotation.x - deg_to_rad(event.relative.y * m_pitch * sensitivity), deg_to_rad(-89.9), deg_to_rad(89.9))
	else:
		if event.is_action_pressed('attack'):
			attack()
		if event.is_action_pressed('attack2'):
			attack2()
		if event.is_action_pressed('use'):
			use()

# I presume this is called every time the physics world gets simulated,
# which is independent of our visual framerate.
func _physics_process(delta):
	# We need to update our `velocity`, which we have, as we extend `CharacterBody3D`.

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# TODO try additive jump velocity like Quake 2
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# TODO acceletation
	var input_dir = Input.get_vector("moveleft", "moveright", "forward", "back")
	var wishdir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if wishdir:
		velocity.x = wishdir.x * speed
		velocity.z = wishdir.z * speed
	else:
		# move_toward is just a math interpolation function,
		# here it "moves" our velocity towards our speed,
		# it doesn't move us.
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Now that we have figured out our velocity,
	# `CharacterBody3D.move_and_slide()` tells the physics engine to
	# move us with our velocity, and to "slide" along walls which
	# we collide with.
	# 
	# In other words (in the physics engine),
	# we move, do collision detection and
	# "slide" along walls as to resolve possible collision.
	move_and_slide()
