extends Node2D
class_name UnitGroup


signal turn_complete

@export
var group_name: String
@export
var is_player_group: bool = false

var current_unit: UnitInstance
var current_unit_index: int = -1
var hovered_unit: UnitInstance

var is_awaiting_unit_selection: bool = false
var is_turn: bool = false

func init() -> void:
	for unit in get_active_units():
		unit.unit_mouse_entered.connect(_unit_mouse_entered)
		unit.unit_mouse_exited.connect(_unit_mouse_exited)


func get_active_units() -> Array[UnitInstance]:
	var out: Array[UnitInstance] = []
	for child in get_children():
		if child is UnitInstance:
			out.append(child)
	return out

func get_active_units_by_cell() -> Dictionary[Vector2i, UnitInstance]:
	var out : Dictionary[Vector2i, UnitInstance] = {}
	for child in get_children():
		if child is UnitInstance:
			out[child.cell] = child
	return out

func is_active() -> bool:
	return get_active_units().size() > 0


func take_turn() -> void:
	current_unit_index = -1
	is_turn = true
	for unit in get_active_units():
		unit.reset_turn()
	_step_turn()

func _step_turn() -> void:
	EventBus.clear_cell_highlights.emit()
	## Clear highlights
	## Wait for things to happen
	if is_player_group:
		_step_turn_player()
	else:
		_step_turn_ai()

func _end_turn() -> void:
	is_awaiting_unit_selection = false
	is_turn = false
	turn_complete.emit()

func _step_turn_player() -> void:
	
	var unused_units = get_unused_units()
	if unused_units.is_empty():
		_end_turn()
		return
	
	_disconnect_current_unit_signals()
	EventBus.clear_cell_highlights.emit()
	
	current_unit = null
	is_awaiting_unit_selection = true
	
	EventBus.show_selectable_player_units.emit(
		unused_units.map(func (unit): return unit.cell)
	)
	
	

## TODO: Dear lord this needs refactoring
func _unhandled_input(event: InputEvent) -> void:
	if not is_player_group or not is_turn:
		return
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_awaiting_unit_selection and hovered_unit != null:
				get_viewport().set_input_as_handled()
				is_awaiting_unit_selection = false
				current_unit = hovered_unit
				_connect_current_unit_signals()
			elif current_unit != null:
				var mouse_pos: Vector2i = Vector2i((get_viewport().get_mouse_position()/Constants.TILE_SIZE).floor())
				if mouse_pos in current_unit.get_moveable_cells():
					await current_unit.move_to(mouse_pos)
					EventBus.clear_cell_highlights.emit()
					
					EventBus.update_pathfinding.emit()
					current_unit.taken_turn = true
					current_unit = null
					EventBus.show_selectable_player_units.emit(
						get_unused_units().map(func (unit): return unit.cell)
					)
					_step_turn()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if current_unit != null and not is_awaiting_unit_selection:
				get_viewport().set_input_as_handled()
				is_awaiting_unit_selection = true
				_disconnect_current_unit_signals()
				var old_unit := current_unit
				current_unit = null
				if hovered_unit != null:
					if old_unit.get_instance_id() == hovered_unit.get_instance_id():
						return
				EventBus.hide_unit_move_range_highlight.emit(old_unit)

func _step_turn_ai() -> void:
	
	var unused_units := get_unused_units()
	
	if unused_units.is_empty():
		_end_turn()
		return
	var unit : UnitInstance = unused_units.front()
	
	var new_cell : Vector2i = unit.get_moveable_cells().pick_random()
	await unit.move_to(new_cell)
	unit.taken_turn = true
	EventBus.update_pathfinding.emit()
	_step_turn()


func _connect_current_unit_signals() -> void:
	pass

func _disconnect_current_unit_signals() -> void:
	pass

func get_unused_units() -> Array[UnitInstance]:
	return get_active_units().filter(func (unit: UnitInstance): return not unit.taken_turn)

func _unit_mouse_entered(unit: UnitInstance) -> void:
	hovered_unit = unit
	EventBus.show_unit_move_range_highlight.emit(unit)
	


func _unit_mouse_exited(unit: UnitInstance) -> void:
	if hovered_unit.get_instance_id() == unit.get_instance_id():
		hovered_unit = null
		if current_unit != null:
			if unit.get_instance_id() == current_unit.get_instance_id():
				return
		EventBus.hide_unit_move_range_highlight.emit(unit)
