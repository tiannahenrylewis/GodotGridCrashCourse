class_name BuildingComponent
extends Node2D

@export_file("*.tres") var building_resource_path: String
var building_resource: BuildingResource

func _ready() -> void:
	if building_resource_path != null:
		building_resource = load(building_resource_path)
	
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
