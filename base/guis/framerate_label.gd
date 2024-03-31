class_name FramerateLabel
extends Label

@export var items : Dictionary = {0: Color.RED, 15: Color.ORANGE, 30: Color.YELLOW, 60: Color.GREEN, 120: Color.CYAN}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fps : float = Engine.get_frames_per_second()
	var color : Color

	for threshold in items:
		if fps >= threshold - 0.5:
			color = items[threshold]

	var format = "%.2f / %.2f FPS"
	text = format % [fps, Engine.max_fps]
	add_theme_color_override("font_color", color)
