extends Node

@onready var grid_Manager = $GridManager
@onready var gold_mine = %GoldMine

func _ready() -> void:
	GameEvents.connect("grid_state_updated_signal", _on_grid_state_updated)


func _on_grid_state_updated():
	var gold_mine_tile_position = grid_Manager.convert_world_position_to_tile_position(gold_mine.global_position)
	if grid_Manager.is_tile_position_buildable(gold_mine_tile_position):
		gold_mine.set_active()
