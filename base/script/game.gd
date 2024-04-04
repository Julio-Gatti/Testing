## The game main loop.
class_name Game
extends SceneTree

@export var player_scene : PackedScene = preload("res://base/def/player.tscn")
@export var hud_scene : PackedScene = preload("res://base/guis/hud.tscn")

func _init() -> void:
	print(get_class(), ' _init')

func _initialize() -> void:
	print(get_class(), ' _initialize')

	# Translation, rotation and scale (TRS) (Transformation)
	# Don't care about scale
	var start_pos : Vector3
	var start_rad : Vector3
	var start_node : Node3D = current_scene.find_child('info_player_start')

	if start_node:
		start_pos = start_node.position
		start_rad = start_node.rotation
	else:
		printerr('No info_player_start node in scene')
		start_pos = Vector3.ZERO
		start_rad = Vector3.ZERO

	start_pos += Vector3.UP * 0.10

	var player : Node3D = player_scene.instantiate()
	player.position = start_pos
	player.rotation = start_rad
	root.add_child(player)
	print('Spawned player at ', player.global_position, player.global_rotation)
	
	var hud : Node = hud_scene.instantiate()
	root.add_child(hud)
