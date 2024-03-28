# Essentially just something to hold in the view.
class_name Weapon
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Primary fire. Called by the attacker upon primary attacking.
# Could I fire your weapon? Maybe :)
func fire(attacker):
	# TODO
	if attacker:
		pass
	else:
		# Went off by itself, lol.
		pass

# Secondary fire. Called by the attacker upon secondary attacking.
func fire2(attacker):
	# TODO
	pass
