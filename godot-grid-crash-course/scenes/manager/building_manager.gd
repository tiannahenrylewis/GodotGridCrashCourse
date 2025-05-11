extends Node

@export var game_ui: Control
@export var grid_manager: Node
@export var y_sort_root: Node2D
@export var building_ghost_scene: PackedScene

enum State {
	NORMAL,
	PLACING_BUILDING
}

const ACTION_LEFT_CLICK: StringName = "left_click"
const ACTION_CANCEL: StringName = "cancel"
const ACTION_RIGHT_CLICK: StringName = "right_click"

var current_resource_count: int
var starting_resource_count: int = 4
var currently_used_resource_count: int
var to_place_building_resource: BuildingResource
var hovered_grid_cell: Vector2i = Vector2i(-1, -1)
var null_cell_value = Vector2(-10,-10)
var building_ghost: Node2D
var current_state: State = State.NORMAL

func _ready():
	GameEvents.connect("resource_tiles_updated", _on_resource_tiles_updated)
	GameEvents.connect("building_resource_selected_signal", _on_building_resource_selected)


func _process(_delta: float) -> void:	
	var grid_position = grid_manager.get_mouse_grid_cell_position()
	
	if hovered_grid_cell != grid_position:
		 # reassign the hovered_grid_cell
		hovered_grid_cell = grid_position
		update_hovered_grid_cell()
	
	match current_state:
		State.NORMAL:
			pass
		State.PLACING_BUILDING:
			# set the cursor to the mouse position
			building_ghost.global_position = grid_position * 64 


func _unhandled_input(event: InputEvent) -> void:
	match current_state:
		State.NORMAL:
			if event.is_action_pressed(ACTION_RIGHT_CLICK):
				destroy_building_at_hovered_cell_position()
		State.PLACING_BUILDING:
			if event.is_action_pressed(ACTION_CANCEL):
				change_state(State.NORMAL)
			elif (to_place_building_resource != null && 
			event.is_action_pressed(ACTION_LEFT_CLICK) && 
			_is_building_placeable_at_tile(hovered_grid_cell)):
				# place building
				place_building_at_hovered_cell_position()
		_:
			pass


func _update_grid_display():
	grid_manager.clear_highlighted_tiles() # wiping the entire tileset
	grid_manager.highlight_buildable_tiles() # re-highlighting the tiles that are currently buildable

	
	if _is_building_placeable_at_tile(hovered_grid_cell):
		grid_manager.highlight_expanded_buildable_tiles(hovered_grid_cell, to_place_building_resource.buildable_radius)
		grid_manager.highlight_resource_tiles(hovered_grid_cell, to_place_building_resource.resource_radius)
		building_ghost.set_valid()
	else:
		building_ghost.set_invalid()


func place_building_at_hovered_cell_position():
	var building = to_place_building_resource.building_scene.instantiate() as Node2D
	y_sort_root.add_child(building)
	
	building.global_position = hovered_grid_cell * 64
	currently_used_resource_count += to_place_building_resource.resource_cost
	change_state(State.NORMAL)


func destroy_building_at_hovered_cell_position():
	pass


func clear_building_ghost():
	grid_manager.clear_highlighted_tiles()
	
	if is_instance_valid(building_ghost):
		building_ghost.queue_free()
	
	# ensures the reference is null as soon as the node has been queued up for deletion
	building_ghost = null 


# number of resources available
func get_available_resource_count() -> int:
	return starting_resource_count + current_resource_count - currently_used_resource_count


func update_hovered_grid_cell():
	match current_state:
		State.NORMAL:
			pass
		State.PLACING_BUILDING:
			_update_grid_display()


func change_state(to_state: State):
	match current_state:
		State.NORMAL:
			pass
		State.PLACING_BUILDING:
			clear_building_ghost()
			to_place_building_resource = null
	
	current_state = to_state
	
	match current_state:
		State.NORMAL:
			pass
		State.PLACING_BUILDING:
			building_ghost = building_ghost_scene.instantiate()
			y_sort_root.add_child(building_ghost) #unorphan building_ghost
	


func hasValue(cell: Vector2) -> bool:
	if cell == null_cell_value:
		return false
	else:
		return true


func _on_building_resource_selected(building_resource: BuildingResource):
	change_state(State.PLACING_BUILDING)
	# add sprite as child to building ghost
	var building_sprite = building_resource.sprite_scene.instantiate()
	building_ghost.add_child(building_sprite)
	to_place_building_resource = building_resource
	_update_grid_display()


func _is_building_placeable_at_tile(tile_position: Vector2i) -> bool:
	return grid_manager.is_tile_position_buildable(tile_position) && get_available_resource_count() >= to_place_building_resource.resource_cost


func _on_resource_tiles_updated(resource_count: int):
	current_resource_count = resource_count
