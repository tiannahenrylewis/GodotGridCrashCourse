class_name BuildingComponent
extends Node2D

# Is there a way to make this only read-only
@export var buildable_raidus: int


func _ready() -> void:
	# TODO: Consider moving to a global constants file so can be referenced in one place
	add_to_group("BuildingComponent")
	# Because ready method is happening before the global position is set and we 
	# neet it to be set before emitting the signal, call_deferred() will wait until 
	# other Godot processes are finished, so call this function last, at the end.
	Callable(func(): 
		GameEvents.emit_building_placed(self)
	).call_deferred()


func get_grid_cell_position() -> Vector2i:
	# divide x and y by 64
	var grid_position = global_position / 64
	# round down the grid position
	grid_position = grid_position.floor() 
	return Vector2i(grid_position)
