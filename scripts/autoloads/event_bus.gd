extends Node

## TODO: Work out which signals are actually needed

@warning_ignore("unused_signal")
signal highlight_cell(cell: Vector2i, type: CellHighlight.Type)


# Signals that definitly get used

@warning_ignore("unused_signal")
signal show_unit_move_range_highlight(unit: UnitInstance)
@warning_ignore("unused_signal")
signal hide_unit_move_range_highlight(unit: UnitInstance)
@warning_ignore("unused_signal") ## Unsure about this one if its still needed
signal clear_cell_highlights
@warning_ignore("unused_signal")
signal show_selectable_player_units(cells: Array)
@warning_ignore("unused_signal")
signal queue_turn_start(group_name: String, group_index: int)
@warning_ignore("unused_signal")
signal turn_start_ready
@warning_ignore("unused_signal")
signal update_pathfinding
