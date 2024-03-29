## Actor
class_name Player3D
extends Actor3D

@onready var camera : Camera3D = $FPSCamera3D
@onready var ray : RayCast3D = $FPSCamera3D/RayCast3D

# Quake mouse pitch coefficient.
@export var m_pitch : float = 0.022
# Quake mouse yaw coefficient.
@export var m_yaw : float = 0.022
# Quake mouse sensitivity.
@export var sensitivity : float = 4.0

# Either an array of nodes or just parent to an inventory node...
var inventory : Inventory
var weapon : Weapon3D

# Called upon being added to the `SceneTree`, so essentially upon spawning.
func _enter_tree():
	print(get_class(), '._enter_tree')
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	# TODO Quake "think"
	pass

# Quake +attack
func attack():
	if weapon and weapon.has_method('fire'):
		# Smalltalk style messaging?
		# In a Simula based language like C++ this wouldn't even compile.
		# Extremely late binding?
		weapon.fire(self)

func attack2():
	if weapon and weapon.has_method('fire2'):
		weapon.fire2(self)

# Quake +use
func use():
	var interactable = ray.get_collider()

	if interactable and interactable.has_method('interact'):
		print('use ', interactable)
		interactable.interact(self)
	else:
		# Why does GDScript try to C style backslash escape a '' string?
		# Isn't a '' string precisely a non escaped string, or is that just a JavaScript thing?
		print('use: no interactable')

func toggleconsole():
	print('toggleconsole')

func exit(exit_code: int = 0):
	get_tree().quit(exit_code)

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
		if event.is_action_pressed('toggleconsole'):
			toggleconsole()
		if event.is_action_pressed('ui_cancel'): # escape
			exit()

# Add stuff to inventory
func add(item : Item3D):
	inventory.add(item)

# Quake wishdir
var wishdir : Vector3
## Ground acceleration.
@export var acceleration : float = 32
## Ground deceleration.
@export var deceleration : float = 8

func _physics_process(delta):
	# No super yet!
	
	# Get the input direction and handle the movement/deceleration.
	# TODO acceletation
	var input_dir = Input.get_vector("moveleft", "moveright", "forward", "back")
	wishdir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if wishdir: # length > 0
		# wants to accelerate
		# but are we in the air?
		if is_on_floor():
			velocity.x = lerp(velocity.x, wishdir.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, wishdir.z * speed, acceleration * delta)
		else:
			# TODO still allow smaller changes to velocity
			pass
	else:
		# wants to decelerate
		# but are we in the air?
		if is_on_floor():
			# move_toward is just a math interpolation function,
			# here it "moves" our velocity towards our speed,
			# it doesn't move us.
			velocity.x = lerp(velocity.x, move_toward(velocity.x, 0, speed), deceleration * delta)
			velocity.z = lerp(velocity.z, move_toward(velocity.z, 0, speed), deceleration * delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump()
	
	super._physics_process(delta)
