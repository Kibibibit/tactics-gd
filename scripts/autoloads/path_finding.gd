extends Node


var _a_star: AStar2D
var _used_rect: Rect2i
var _get_active_units_callback: Callable

const NEIGHBOURS: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

func _compute_id(v: Vector2i) -> int:
	return (v.y) * _used_rect.size.y + (v.x)

func _vector_from_id(id: int) -> Vector2i:
	return Vector2((id % _used_rect.size.y), floori(id as float / _used_rect.size.y ))

func init_level(tilemap: TileMapLayer, get_active_units) -> void:
	_a_star = AStar2D.new()
	_get_active_units_callback = get_active_units
	_used_rect = tilemap.get_used_rect()
	

	
	var ids: Array[int] = []
	
	
	for _x in _used_rect.size.x:
		for _y in _used_rect.size.y:
			var x : int = _x + _used_rect.position.x
			var y : int = _y + _used_rect.position.y
			var id: int = _compute_id(Vector2i(x,y))
			
			var tiledata: TileData = tilemap.get_cell_tile_data(Vector2i(x,y))
			var cost: int = tiledata.get_custom_data_by_layer_id(0) as int
			
			if cost > 0:
				_a_star.add_point(id, Vector2(x,y)*Constants.TILE_SIZE, cost as float)
				ids.append(id)
	for id in ids:
		var v: Vector2i = _vector_from_id(id)
		for n in NEIGHBOURS:
			var n_id: int = _compute_id(Vector2i(v+n))
			if _a_star.has_point(n_id):
				_a_star.connect_points(id, n_id, true) 
	
	_update_pathfinding()
	EventBus.update_pathfinding.connect(_update_pathfinding)

func get_reachable_cells(unit: UnitInstance) -> Array[Vector2i]:
	var start: Vector2i = unit.cell
	var start_id: int = _compute_id(start)
	
	var spiral_size: int = 1
	
	var out: Array[Vector2i] = []
	
	while spiral_size < unit.unit_def.move_range*2:
		
		var cell: Vector2i = start-Vector2i(spiral_size, spiral_size)
		var found_valid: bool = false
		for dir in NEIGHBOURS:
			for _i in range(2*spiral_size):
				
				var target_id: int = _compute_id(cell)
				if _a_star.has_point(target_id) and not _a_star.is_point_disabled(target_id):
					var path_length: int = _a_star.get_point_path(start_id, _compute_id(cell)).size()-1
					if path_length >= 0 and path_length <= unit.unit_def.move_range:
						out.append(cell)
						found_valid = true
				cell += dir
		spiral_size+=1
		
		if not found_valid:
			break
		
	
	return out


func _get_active_units() -> Array[UnitInstance]:
	var out: Array[UnitInstance] = []
	for v in _get_active_units_callback.call():
		if v is UnitInstance:
			out.append(v)
	return out

func _update_pathfinding() -> void:
	var filled_spaces: Array[int] = []
	for _unit in _get_active_units():
		filled_spaces.append(_compute_id(_unit.cell))
	for id in _a_star.get_point_ids():
		_a_star.set_point_disabled(id, id in filled_spaces)
