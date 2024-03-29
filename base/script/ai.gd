## Skynet tier AI.
class_name AI3D
extends Actor3D

var next_idle : float
@export var idle_sound : AudioStream = preload('res://base/sound/zombie/idle.tres')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func make_idle_sound():
	
	print('bruh')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Screw the timer class
	next_idle -= delta
	if next_idle <= 0:
		make_idle_sound()
