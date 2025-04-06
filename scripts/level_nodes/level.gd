extends Node
class_name Level


@export_group("Nodes")
@export var tilemap: TileMapLayer
@export var units: UnitManager
@export var ui: LevelUI

# Init everything
# Generates maps
# Listens for win/loss conditions



func _ready() -> void:
	
	### Could set a seed here if wanted
	
	units.init()
	
	PathFinding.init_level(tilemap, units.get_active_units)
	
	units.start_battle()
