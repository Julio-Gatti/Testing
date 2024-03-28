# The idea is that this is the "hand" of the player, in front of the camera.
class_name Inventory
extends Node3D

# Either this, or just use the children nodes.
# var items : Array[Item3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add(item : Item3D):
	assert(item != null, "Shouldn't add nulls to the inventory.")

	print(get_class(), '.add(', item, ')')
	add_child(item)
	# https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-print-tree
	print_tree()
