class_name Actor3D
extends CharacterBody3D

# Spawnflags
# Horrible unnamed and unscoped enum like in C? YES!
# https://github.com/id-Software/Quake-2/blob/master/game/g_local.h#L48
enum {
	SPAWNFLAG_NOT_EASY			= 1 << 0,	# 1: Doesn't spawn on easy
	SPAWNFLAG_NOT_MEDIUM		= 1 << 1,	# 2: Doesn't spawn on medium
	SPAWNFLAG_NOT_HARD			= 1 << 2,	# 4: Doesn't spawn on hard
	SPAWNFLAG_NOT_DEATHMATCH	= 1 << 3,	# 8: Doesn't spawn in deathmatch
	SPAWNFLAG_NOT_COOP			= 1 << 4,	# 16: Doesn't spawn in coop
}

# Halleluja.
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#exporting-bit-flags
@export_flags(
	"Not on Easy:1",
	"Not on Medium:2",
	"Not on Hard:4",
	"Not in Deathmatch:8",
	"Not in Coop:16") var spawnflags : int = 0

# Damage type flags
# https://github.com/ValveSoftware/halflife/blob/master/ricochet/cl_dll/eventscripts.h#L25
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

## Maximum movement speed.
@export var speed = 5.0
@export var jump_velocity = 4.5

# Get the gravity from the project settings to be synced with `RigidBody` nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# This syntax for returning something sucks, lol
func is_noclip() -> bool:
	return motion_mode == CharacterBody3D.MOTION_MODE_FLOATING

func noclip():
	if is_noclip():
		print(name, ': noclip off')
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	else:
		print(name, ': noclip on')
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

# Audio source to not be able to "speak" sounds overlapping.
@onready var voice : AudioStreamPlayer3D = $Voice

@export_range(1, 65535) var health : int = 100
var dead : bool = false

# kinda sucks
var was_in_air : bool
# might be in Godot already somewhere
var last_velocity : Vector3

## How much this guy takes the fall damagellsssssttt `* m/s`
@export var falling_damage_multiplier : float = 1.5

@export var jump_sound : AudioStream = preload('res://base/sound/ranger/jmp.wav')
@export var pain_sound : AudioStream = preload('res://base/sound/ranger/pain.tres')
@export var death_sound : AudioStream = preload('res://base/sound/ranger/death1.wav')
@export var h20death_sound : AudioStream = preload('res://base/sound/ranger/h2odeath.wav')
@export var gib_sound : AudioStream = preload('res://base/sound/ranger/gib.wav')

func _init():
	floor_constant_speed = true

func _ready():
	assert(floor_constant_speed, 'Should be set')

	if !voice:
		# TODO warning?
		printerr(name, ' has no voice, creating it, sound will come from feet')
		voice = AudioStreamPlayer3D.new()
		add_child(voice)

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

func pain(amount : float, flags : int):
	# I don't care about health going below zero, it's a feature for gibbing.
	# GDScript doesn't support C style cast :(
	health -= int(amount)
	if health < 0:
		# Should get the appropriate death sound for damage type
		if flags & DMG_DROWN:
			voice.stream = h20death_sound
		else:
			voice.stream = death_sound
		voice.play()
	else:
		voice.stream = pain_sound
		voice.play()

## m/s
@export var falling_damage_velocity_threshold : float = 9.9

func landed():
	# Current UP velocity is 0 already, so use last velocity
	print('landed velocity: ', last_velocity)
	was_in_air = false

	# Falling damage
	# Treshold
	# abs if head hit ceiling? xd
	if abs(last_velocity.y) > falling_damage_velocity_threshold:
		# var damage : Damage
		# What the fuck? Does this not work like C? :D
		#damage.amount = abs(last_velocity.y) * falling_damage_multiplier
		#damage.flags = DMG_FALL
		# Causer is worldspawn in Quake/Source, soooo... root node? :D
		#damage.causer = get_tree().current_scene
		# Should be the one who knocked you off a ledge
		#damage.instigator = null
		var damage_amount = abs(last_velocity.y) * falling_damage_multiplier
		pain(damage_amount, DMG_FALL)

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
