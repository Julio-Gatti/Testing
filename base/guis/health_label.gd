class_name HealthLabel
extends Label

var player : Player3D

# Called when the node enters the scene tree for the first time.
func _ready():
	# How the fuck to get player?
	player = get_tree().current_scene.find_child("Player")
	# This sucks anyway. Someday good.
	assert(player, "No player in scene?")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "health: %d" % player.health
	pass
