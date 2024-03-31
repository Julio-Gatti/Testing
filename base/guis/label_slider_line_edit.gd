class_name LabelSliderLineEdit
extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var slider : Slider = $Slider

func _on_line_edit_text_submitted(new_text):
	slider.value = new_text
