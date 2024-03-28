# Essentially just something to hold in the view.
class_name Weapon3D
extends Item3D

# `Firearm` muzzleflash or `Flashlight` light source.
@onready var light : SpotLight3D = $SpotLight3D

# `Firearm` ammunition or `Flashlight` battery.
@export var ammo : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Primary fire. Called by the attacker upon primary attacking.
# Could I fire your weapon? Maybe :)
func fire(attacker):
	# Undefined, I guess
	pass

# Secondary fire. Called by the attacker upon secondary attacking.
func fire2(attacker):
	# Undefined, I guess
	pass
