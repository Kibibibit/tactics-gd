extends Node


const TILE_SIZE: int = 16


const TEAM_COLORS: Array[Color] = [
	Color.BLUE,
	Color.RED,
]


func get_team_color(team_index: int) -> Color:
	if team_index < TEAM_COLORS.size() and team_index >= 0:
		return TEAM_COLORS[team_index]
	else:
		return Color(randf(), randf(), randf())
