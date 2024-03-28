class_name Item3D
extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Primary fire. Called by the attacker upon primary attacking.
func fire(attacker):
	# Undefined, I guess
	pass

# Secondary fire. Called by the attacker upon secondary attacking.
func fire2(attacker):
	# Undefined, I guess
	pass

func interact(user):
	# TODO this sucks.
	if (user.has_method('add')):
		user.add(self)
