@tool
extends ColorRect
class_name TurnStartAnimation


const SHADER_PARAM_COLOR: StringName = &"color"
const SHADER_PARAM_PROGRESS: StringName = &"progress"
const SHADER_PARAM_WIDTH: StringName = &"width"
const SHADER_PARAM_ANGLE: StringName = &"angle"

@export_tool_button("Run Ready Function")
@warning_ignore("unused_private_class_variable")
var _tool_button_action = _ready

@export_range(0,1.5, 0.01)
var animation_progress: float = 0.0: set = _set_animation_progress
@export
var wipe_width: float = 0.3




var label: Label
var animation_player: AnimationPlayer

var _screen_width: float
var _screen_height: float
var _mat: ShaderMaterial

@export
var group_name: String = "[GROUP]"

func _ready() -> void:
	label = $Label
	animation_player = $AnimationPlayer
	_mat = material as ShaderMaterial
	label.text = "%s TURN" % group_name.to_upper()
	label.update_minimum_size()
	_screen_width = get_viewport_rect().size.x
	_screen_height = get_viewport_rect().size.y
	label.position.y =  (_screen_height as float) /2.0
	animation_progress = 0
	label.position.x = -label.size.x
	

func play() -> bool:
	animation_player.play("turn_start_animations/turn_start")
	await animation_player.animation_finished
	return true

func _set_animation_progress(v: float):
	animation_progress = v
	label.position.x = lerp(-label.size.x, _screen_width-label.size.x, animation_progress)
	_mat.set_shader_parameter(SHADER_PARAM_COLOR, color)
	_mat.set_shader_parameter(SHADER_PARAM_PROGRESS, animation_progress)
	_mat.set_shader_parameter(SHADER_PARAM_WIDTH, wipe_width)


static func create(_group_name: String, _color: Color) -> TurnStartAnimation:
	var out: TurnStartAnimation = preload("res://scenes/animations/turn_start_animation.tscn").instantiate()
	out.color = _color
	out.group_name = _group_name
	return out
