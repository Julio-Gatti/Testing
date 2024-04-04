class_name OptionsMenu
extends Control

@onready var sfx_volume_slider : HSlider = $BoxContainer/SFXVolumeSlider
@onready var music_volume_slider: HSlider = $BoxContainer/MusicVolumeSlider
@onready var fullscreen_button: OptionButton = $BoxContainer/FullscreenButton
@onready var render_scale_current_value_label: Label = $BoxContainer/RenderScaleCurrentValueLabel
@onready var render_scale_slider: HSlider = $BoxContainer/RenderScaleSlider
@onready var vsync_button: OptionButton = $BoxContainer/VSyncButton
@onready var invert_y_check_button: CheckButton = $BoxContainer/InvertYAxisCheckButton
@onready var anti_aliasing_2d_option_button: OptionButton = $BoxContainer/AntiAliasing2DOptionButton
@onready var anti_aliasing_3d_option_button: OptionButton = $BoxContainer/AntiAliasing3DOptionButton

var config = ConfigFile.new()

func go_back():
	save_options()
	emit_signal("close")
	# AWFUL
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func on_open():
	load_options()

# Saves the options when the options menu is closed
func save_options() -> void:
	print('save_options')
	
	# This sucks because Cogito sucks.
	assert(sfx_volume_slider != null)
	assert(render_scale_slider != null)
	
	config.set_value(CVar.section_name, CVar.sfx_volume_key_name, sfx_volume_slider.value)
	config.set_value(CVar.section_name, CVar.music_volume_key_name, music_volume_slider.value)
	config.set_value(CVar.section_name, CVar.fullscreen_key_name, fullscreen_button.get_index())
	config.set_value(CVar.section_name, CVar.render_scale_key, render_scale_slider.value)
	config.set_value(CVar.section_name, CVar.vsync_key, vsync_button.get_index())
	#config.set_value(CVar.section_name, CVar.invert_vertical_axis_key, invert_y_check_button.button_pressed)
	#config.set_value(CVar.section_name, CVar.msaa_2d_key, anti_aliasing_2d_option_button.get_selected_id())
	#config.set_value(CVar.section_name, CVar.msaa_3d_key, anti_aliasing_3d_option_button.get_selected_id())
	
	config.save(CVar.config_file_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(sfx_volume_slider != null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_options():
	var err = config.load(CVar.config_file_name)
	
	var fullscreen = config.get_value(CVar.section_name, CVar.fullscreen_key_name, false)
	
	fullscreen_button.emit_signal("item_selected", fullscreen)

func _input(event):
	if event.is_action_pressed("ui_cancel") && visible:
		accept_event()
		go_back()

static func set_volume(bus_index, value):
	print("Setting volume on bus_index ", bus_index, " to ", value)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

static func _on_sfx_volume_slider_value_changed(value):
	set_volume(AudioServer.get_bus_index(CVar.sfx_bus_name), value)

static func _on_music_volume_slider_value_changed(value):
	set_volume(AudioServer.get_bus_index(CVar.music_bus_name), value)

static func _on_fullscreen_button_item_selected(index):
	DisplayServer.window_set_mode(index)

func _on_vsync_button_item_selected(index):
	DisplayServer.window_set_vsync_mode(index)
