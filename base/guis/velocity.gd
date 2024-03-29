class_name VelocityLabel
extends Label

var player : Player3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.find_child("Player")
	# This sucks anyway. Someday good.
	assert(player, "No player in scene?")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "velocity: %s" % player.velocity
