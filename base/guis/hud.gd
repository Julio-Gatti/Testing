class_name HUD
extends Control

@onready var menu : Control = $Menu

# Called when the node enters the scene tree for the first time.
func _ready():
	menu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed('ui_cancel'): # escape
		# PÄÄSTÄ IRTI!
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		menu.visible = true
