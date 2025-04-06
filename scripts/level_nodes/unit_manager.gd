extends Node2D
class_name UnitManager


signal battle_over(player_won: bool)

# Handles taking turns
# Cycles through unit gruops
# Cross group logic -> Where are active units and so on
# Delegates most things

var all_groups: Array[UnitGroup] = []

var current_group_index: int = 0
var current_group: UnitGroup

var player_group: UnitGroup



func init() -> void:
	var i: int = 0
	for child in get_children():
		if child is UnitGroup:
			child.init()
			all_groups.append(child)
			if child.is_player_group:
				player_group = child
				current_group = child
				current_group_index = i
			child.turn_complete.connect(_next_turn)


func get_active_units() -> Array[UnitInstance]:
	var out: Array[UnitInstance] = []
	for group in _get_active_groups():
		out.append_array(group.get_active_units())
	return out
			

func start_battle() -> void:
	_begin_turn()

func _next_turn() -> void:
	var prev_group_index: int = current_group_index
	while true:
		current_group_index = wrapi(current_group_index + 1, 0, all_groups.size())
		current_group = all_groups[current_group_index]
		if current_group.is_active():
			break
		if current_group_index == prev_group_index:
			push_error("Could not find another active unit group!")
			break
	_begin_turn()
		
	

func _begin_turn() -> void:
	EventBus.queue_turn_start.emit(current_group.group_name, current_group_index)
	await EventBus.turn_start_ready
	current_group.take_turn()

func _get_active_groups() -> Array[UnitGroup]:
	return all_groups.filter(func (group: UnitGroup):
		return group.is_active())

func _on_turn_complete() -> void:
	
	if _get_active_groups().size() > 1:
		_next_turn()
		return
	
	battle_over.emit(player_group.is_active())
