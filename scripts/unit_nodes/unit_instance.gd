@tool
extends Node2D
class_name UnitInstance

signal unit_mouse_entered(unit: UnitInstance)
signal unit_mouse_exited(unit: UnitInstance)

signal unit_finished_move


@export
var unit_def: UnitDef ## Adjust texture and stuff here

@export
var cell: Vector2i : set = _set_cell

@export_group("Nodes")
@export var sprite: AnimatedSprite2D
@export var mouse_area: Area2D

var taken_turn: bool = false
var moving: bool = false

var _needs_cell_update: bool = true
var _moveable_cells: Array[Vector2i] = []


func _ready() -> void:
	mouse_area.mouse_entered.connect(func(): unit_mouse_entered.emit(self))
	mouse_area.mouse_exited.connect(func(): unit_mouse_exited.emit(self))
	EventBus.update_pathfinding.connect(func(): 
		_needs_cell_update = true
		_moveable_cells = []
	)


func reset_turn() -> void:
	taken_turn = false
	_needs_cell_update = true
	_moveable_cells = []

func get_moveable_cells() -> Array[Vector2i]:
	if _needs_cell_update:
		_moveable_cells = PathFinding.get_reachable_cells(self)
		_needs_cell_update = false
	return _moveable_cells

func _set_cell(v: Vector2i) -> void:
	cell = v
	if Engine.is_editor_hint():
		position = _cell_world_pos(v)

func move_to(new_cell: Vector2i) -> void:
	cell = new_cell
	moving = true
	await unit_finished_move

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	position = position.lerp(_cell_world_pos(cell), 30.0*delta)
	
	if moving:
		if position.distance_squared_to(_cell_world_pos(cell)) < 0.5:
			moving = false
			unit_finished_move.emit()

func _cell_world_pos(c: Vector2i) -> Vector2:
	return Vector2(c*Constants.TILE_SIZE) + (Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)/2.0)
