# Weapon
class_name Flashlight
extends Weapon3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Primary fire. Called by the attacker upon primary attacking.
func fire(attacker):
	# Light visibility is all the way back in `Node3D`!
	if light.visible:
		light.visible = false
		# TODO play enabled sound
		# TODO affect some material emission param
	else:
		light.visible = true
		# TODO play enabled sound

# Secondary fire. Called by the attacker upon secondary attacking.
func fire2(attacker):
	# I'll take a pass.
	pass
