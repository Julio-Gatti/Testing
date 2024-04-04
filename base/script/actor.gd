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
@export var jump_velocity = 5.0

## STAIR HANDLING STUFF
@export_group("Stair Handling")
var is_step : bool = false
var step_check_height : Vector3 = STEP_HEIGHT_DEFAULT / STEP_CHECK_COUNT
var head_offset : Vector3 = Vector3.ZERO
## This sets the camera smoothing when going up/down stairs as the player snaps to each stair step.
@export var step_height_camera_lerp : float = 2.5
## This sets the height of what is still considered a step (instead of a wall/edge)
@export var STEP_HEIGHT_DEFAULT : Vector3 = Vector3(0, 0.5, 0)
## This sets the step slope degree check. When set to 0, tiny edges etc might stop the player in it's tracks. 1 seems to work fine.
@export var STEP_MAX_SLOPE_DEGREE : float = 0.0
const STEP_CHECK_COUNT : int = 2
const WALL_MARGIN : float = 0.001

# Get the gravity from the project settings to be synced with `RigidBody` nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

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

# Cache allocation of test motion parameters.
@onready var _params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()

func get_physics_test_motion_params(transform3d, motion):
	var params : PhysicsTestMotionParameters3D = _params
	params.from = transform3d
	params.motion = motion
	params.recovery_as_collision = true
	return params

@onready var self_rid: RID = self.get_rid()
@onready var test_motion_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()

func test_motion(transform3d: Transform3D, motion: Vector3) -> bool:
	return PhysicsServer3D.body_test_motion(self_rid, get_physics_test_motion_params(transform3d, motion), test_motion_result)

# I presume this is called every time the physics world gets simulated,
# which is independent of our visual framerate.
func _physics_process(delta):
	var snap : Vector3
	var gravity_vec : Vector3
	var is_falling: bool = false

	# We need to update our `velocity`, which we have, as we extend `CharacterBody3D`.
	
	### STAIR FLOOR SNAP
		#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		gravity_vec = Vector3.DOWN * gravity * delta
	###
	
	# Add the gravity.
	if not is_on_floor():
		was_in_air = true
		# NOT YET
		# velocity.y -= gravity * delta
	else:
		snap = -get_floor_normal()
		if was_in_air:
			landed()
	
	last_velocity = velocity
	
	# STAIR HANDLING
	is_step = false
	
	if gravity_vec.y >= 0:
		for i in range(STEP_CHECK_COUNT):
			var step_height: Vector3 = STEP_HEIGHT_DEFAULT - i * step_check_height
			var transform3d: Transform3D = global_transform
			var motion: Vector3 = step_height
			
			var is_player_collided: bool = test_motion(transform3d, motion)
			
			if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).y < 0:
				continue
			
			if not is_player_collided:
				transform3d.origin += step_height
				motion = velocity * delta
				is_player_collided = test_motion(transform3d, motion)
				if not is_player_collided:
					transform3d.origin += motion
					motion = -step_height
					is_player_collided = test_motion(transform3d, motion)
					if is_player_collided:
						if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
							head_offset = -test_motion_result.get_remainder()
							is_step = true
							global_transform.origin += -test_motion_result.get_remainder()
							break
				else:
					var wall_collision_normal: Vector3 = test_motion_result.get_collision_normal(0)

					transform3d.origin += test_motion_result.get_collision_normal(0) * WALL_MARGIN
					motion = (velocity * delta).slide(wall_collision_normal)
					is_player_collided = test_motion(transform3d, motion)
					if not is_player_collided:
						transform3d.origin += motion
						motion = -step_height
						is_player_collided = test_motion(transform3d, motion)
						if is_player_collided:
							if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
								head_offset = -test_motion_result.get_remainder()
								is_step = true
								global_transform.origin += -test_motion_result.get_remainder()
								break
			else:
				var wall_collision_normal: Vector3 = test_motion_result.get_collision_normal(0)
				transform3d.origin += test_motion_result.get_collision_normal(0) * WALL_MARGIN
				motion = step_height
				is_player_collided = test_motion(transform3d, motion)
				if not is_player_collided:
					transform3d.origin += step_height
					motion = (velocity * delta).slide(wall_collision_normal)
					is_player_collided = test_motion(transform3d, motion)
					if not is_player_collided:
						transform3d.origin += motion
						motion = -step_height
						is_player_collided = test_motion(transform3d, motion)
						if is_player_collided:
							if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
								head_offset = -test_motion_result.get_remainder()
								is_step = true
								global_transform.origin += -test_motion_result.get_remainder()
								break

	
	
	if not is_step and is_on_floor():
		var step_height: Vector3 = STEP_HEIGHT_DEFAULT
		var transform3d: Transform3D = global_transform
		var motion: Vector3 = velocity * delta
		var is_player_collided: bool = test_motion(transform3d, motion)
		
		if not is_player_collided:
			transform3d.origin += motion
			motion = -step_height
			is_player_collided = test_motion(transform3d, motion)
			if is_player_collided:
				if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
					head_offset = test_motion_result.get_travel()
					is_step = true
					global_transform.origin += test_motion_result.get_travel()
			else:
				is_falling = true
		else:
			if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).y == 0:
				var wall_collision_normal: Vector3 = test_motion_result.get_collision_normal(0)
				transform3d.origin += test_motion_result.get_collision_normal(0) * WALL_MARGIN
				motion = (velocity * delta).slide(wall_collision_normal)
				is_player_collided = test_motion(transform3d, motion)
				if not is_player_collided:
					transform3d.origin += motion
					motion = -step_height
					is_player_collided = test_motion(transform3d, motion)
					if is_player_collided:
						if test_motion_result.get_collision_count() > 0 and test_motion_result.get_collision_normal(0).angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
							head_offset = test_motion_result.get_travel()
							is_step = true
							global_transform.origin += test_motion_result.get_travel()
					else:
						is_falling = true

	velocity += gravity_vec

	if is_falling:
		snap = Vector3.ZERO

	# Now that we have figured out our velocity,
	# `CharacterBody3D.move_and_slide()` tells the physics engine to
	# move us with our velocity, and to "slide" along walls which
	# we collide with.
	# 
	# In other words (in the physics engine),
	# we move, do collision detection and
	# "slide" along walls as to resolve possible collision.
	move_and_slide()
