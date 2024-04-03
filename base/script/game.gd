## The game main loop.
class_name Game
extends SceneTree

@export var player_scene : PackedScene = preload("res://base/def/player.tscn")

func _init() -> void:
	print(get_class(), ' _init')

func _initialize() -> void:
	print(get_class(), ' _initialize')
	
	var start = current_scene.find_child('info_player_start')
	if start:
		print('Spawning player')
	else:
		printerr('No info_player_start')
	
