class_name Firearm
extends Weapon3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hitscan():
	pass

# Primary fire. Called by the attacker upon primary attacking.
func fire(attacker):
	if ammo: # != 0
		ammo -= 1
		hitscan()

# Secondary fire. Called by the attacker upon secondary attacking.
func fire2(attacker):
	# I'll take a pass.
	pass
