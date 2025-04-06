extends Node2D
class_name CellHighlight

enum Type {SELECTABLE, SELECTED, ATTACK, MOVE}

var _highlights: Dictionary[Vector2i, Type] = {}


var _movement_ranges: Dictionary[int, Array] = {}

func _ready() -> void:
	EventBus.highlight_cell.connect(_highlight_cell)
	EventBus.clear_cell_highlights.connect(_clear_highlights)
	EventBus.show_selectable_player_units.connect(_highlight_selectable_units)
	EventBus.show_unit_move_range_highlight.connect(_show_unit_movement_range_highlight)
	EventBus.hide_unit_move_range_highlight.connect(_hide_unit_movement_range_highlight)

func _highlight_cell(cell: Vector2i, type: Type) -> void:
	_highlights[cell] = type
	queue_redraw()
	
func _clear_highlights() -> void:
	_highlights.clear()
	_movement_ranges.clear()
	queue_redraw()

func _cell_to_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell*Constants.TILE_SIZE),  Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE))

func _highlight_selectable_units(cells: Array) -> void:
	for c in cells:
		if c is Vector2i:
			_highlights[c] = Type.SELECTABLE
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		queue_redraw()

func _draw() -> void:
	_draw_mouse()
	for cell in _highlights:
		match _highlights[cell]:
			Type.SELECTABLE:
				_draw_selectable(cell)
			Type.SELECTED:
				_draw_selected(cell)
			Type.ATTACK:
				pass
			Type.MOVE:
				_draw_move(cell)
			_:
				continue
	for _uid in _movement_ranges:
		for cell in _movement_ranges[_uid]:
			_draw_move(cell as Vector2i)
	

func _draw_mouse() -> void:
	var mouse_pos: Vector2i = Vector2i((get_viewport().get_mouse_position()/Constants.TILE_SIZE).floor())
	draw_rect(_cell_to_rect(mouse_pos), Color.WHITE, false, 1.0)

	
func _draw_selected(cell: Vector2i) -> void:
	draw_rect(_cell_to_rect(cell),  Color(Color.GOLD,0.2))
	draw_rect(_cell_to_rect(cell), Color.GOLD, false, 1.0)
	
func _draw_selectable(cell: Vector2i) -> void:
	draw_rect(_cell_to_rect(cell),  Color(Color.CYAN,0.2))
	draw_rect(_cell_to_rect(cell), Color.CYAN, false, 1.0)

func _draw_move(cell: Vector2i) -> void:
	draw_rect(_cell_to_rect(cell), Color(Color.BLUE, 0.2))

func _show_unit_movement_range_highlight(unit: UnitInstance) -> void:
	_movement_ranges[unit.get_instance_id()] = unit.get_moveable_cells()
	queue_redraw()

func _hide_unit_movement_range_highlight(unit: UnitInstance) -> void:
	_movement_ranges.erase(unit.get_instance_id())
	queue_redraw()
