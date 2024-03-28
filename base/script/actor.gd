class_name Actor3D
extends CharacterBody3D

# Horrible unnamed enum like in C? YES!
# https://github.com/ValveSoftware/halflife/blob/c7240b965743a53a29491dd49320c88eecf6257b/ricochet/cl_dll/eventscripts.h#L25
enum {
	DMG_GENERIC		= 0,
	DMG_CRUSH		= 1 << 0,
	DMG_BULLET		= 1 << 1,
	DMG_SLASH		= 1 << 2,
	DMG_BURN		= 1 << 3,
	DMG_FREEZE		= 1 << 4,
	DMG_FALL		= 1 << 5,
	DMG_BLAST		= 1 << 6,
	DMG_CLUB		= 1 << 7,
	DMG_SHOCK		= 1 << 8,
	DMG_SONIC		= 1 << 9,
	
	DMG_DROWN		= 1 << 14,
}

class Damage:
	var amount : float
	var flags : int
	var causer : Node3D
	var instigator : Node3D

# Maximum movement speed.
@export var speed = 5.0
@export var jump_velocity = 4.5

# Get the gravity from the project settings to be synced with `RigidBody` nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Audio source to not be able to "speak" sounds overlapping.
@onready var voice : AudioStreamPlayer3D = $Voice

@export var health : int = 100
@export var dead : bool = false

# kinda sucks
var was_in_air : bool
# might be in Godot already somewhere
var last_velocity : Vector3

const FALLING_DAMAGE_MULTIPLIER : float = 0.1

@export var jump_sound : AudioStream = preload('res://base/sound/ranger/jmp.wav')
@export var pain_sound : AudioStream = preload('res://base/sound/ranger/pain1.wav')
@export var death_sound : AudioStream = preload('res://base/sound/ranger/death1.wav')
@export var h20death_sound : AudioStream = preload('res://base/sound/ranger/h2odeath.wav')
@export var gib_sound : AudioStream = preload('res://base/sound/ranger/gib.wav')

# Quake +jump
func jump():
	if is_on_floor():
		# TODO try additive jump velocity like Quake 2
		velocity.y = jump_velocity
		voice.stream = jump_sound
		voice.play()
	else:
		print('jump: not on floor')

func gib():
	voice.stream = gib_sound
	voice.play()

func pain(damage):
	# I don't care about health going below zero, it's a feature for gibbing.
	health -= damage.amount
	if health < 0:
		# Should get the appropriate death sound for damage type
		if damage.flags & DMG_DROWN:
			voice.stream = h20death_sound
		else:
			voice.stream = death_sound
		voice.play()
	else:
		voice.stream = pain_sound
		voice.play()

func landed():
	# Current UP velocity is 0 already, so use last velocity
	print('landed velocity: ', last_velocity)
	was_in_air = false
	# Falling damage
	var damage : Damage
	damage.amount = abs(last_velocity.y) * FALLING_DAMAGE_MULTIPLIER
	damage.flags = DMG_FALL
	# Causer is worldspawn in Quake/Source, soooo... root node? :D
	damage.causer = get_tree().current_scene
	# Should be the one who knocked you off a ledge
	damage.instigator = null
	pain(damage)

# I presume this is called every time the physics world gets simulated,
# which is independent of our visual framerate.
func _physics_process(delta):
	# We need to update our `velocity`, which we have, as we extend `CharacterBody3D`.

	# Add the gravity.
	if not is_on_floor():
		was_in_air = true
		velocity.y -= gravity * delta
	elif was_in_air:
		landed()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump()

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

	last_velocity = velocity

	# Now that we have figured out our velocity,
	# `CharacterBody3D.move_and_slide()` tells the physics engine to
	# move us with our velocity, and to "slide" along walls which
	# we collide with.
	# 
	# In other words (in the physics engine),
	# we move, do collision detection and
	# "slide" along walls as to resolve possible collision.
	move_and_slide()
