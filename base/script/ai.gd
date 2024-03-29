## Skynet tier AI.
class_name AI3D
extends Actor3D

@export_group("Vision")

## Horizontal field of view in degrees.
@export_range(0, 360) var fov : float = 170

#@export_category("Barking")

@export_group("Barking Woof Woof Miauu Kot Kot")
var next_idle : float
@export var idle_sound : AudioStream = preload('res://base/sound/zombie/idle.tres')
@export var min_idle_interval : float = 2
@export var max_idle_interval : float = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func make_idle_sound():
	voice.stream = idle_sound
	voice.play()
	next_idle = randf_range(min_idle_interval, max_idle_interval)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Screw the timer class
	next_idle -= delta
	# comparing float with < should be faster as <= converts to int? xd
	if next_idle < 0:
		make_idle_sound()
