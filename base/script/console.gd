class_name Console
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var map_fn = func map(args):
	print('map is ', get_tree().current_scene)

#@export var items : Dictionary = {0: Color.RED, 15: Color.ORANGE, 30: Color.YELLOW, 60: Color.GREEN, 120: Color.CYAN}

var max_fps_fn = func max_fps(args):
	print('max_fps is ', Engine.max_fps)

# GIVE ME C++
var commands : Dictionary = {
	"map": map_fn,
	"max_fps": max_fps_fn
}

func _on_console_input_text_submitted(args):
	var cmd = commands.get(args)
	if cmd:
		# this is so freaking unsafe
		cmd.call(args)
	else:
		print('Unknown command: ', args)
