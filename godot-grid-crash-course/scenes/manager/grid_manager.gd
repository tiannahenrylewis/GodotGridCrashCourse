# GridManager is responsible for keep tracking of all the tiles that are
# buildable (where buildings can be built), what buildings have been built and whire.
extends Node

@export var highlight_tile_map_layer: TileMapLayer 
@export var base_terrain_tile_map_layer: TileMapLayer

var occupied_cells = {}
#OCCUPIED_CELLS CONVIENCEN METHODS
#var my_set = {}
#
## Add an item to the set
#my_set["item_key"] = true
#
## Check if an item exists in the set
#if my_set.has("item_key"):
	#print("Item exists in the set")
#
## Remove an item from the set
#my_set.erase("item_key")
#
## Clear all items (like HashSet.Clear)
#my_set.clear()

func _ready() -> void:
	var game_events = get_node("/root/GameEvents")
	game_events.connect("building_placed_signal", _on_building_placed)

func is_tile_position_valid(tile_position: Vector2i) -> bool:
	var customData = base_terrain_tile_map_layer.get_cell_tile_data(tile_position)
	
	#If data is not available then return false
	if customData == null:
		return false
	
	#If the tile is not marked as `buildable` return false
	if !customData.get_custom_data("buildable"):
		return false
	
	return !occupied_cells.has(tile_position)


func mark_tile_as_occupied(tile_position: Vector2i):
	occupied_cells[tile_position] = true


func highlight_buildable_tiles():
	# TODO: Consider moving to a global constants file so can be referenced in one place
	clear_highlighted_tiles()
	
	var building_components = get_tree().get_nodes_in_group("BuildingComponent") as Array[BuildingComponent]
	
	for building_component in building_components:
		_highlight_valid_tiles_in_radius(building_component.get_grid_cell_position(), building_component.buildable_raidus)


func clear_highlighted_tiles() :
	highlight_tile_map_layer.clear()


func get_mouse_grid_cell_position() -> Vector2i:
	# get mouse position -> returns Vector2(x,y)
	var mouse_position = highlight_tile_map_layer.get_global_mouse_position()
	# divide x and y by 64
	var grid_position = mouse_position / 64
	# round down the grid position
	grid_position = grid_position.floor() 
	return Vector2i(grid_position)


#PRIVATE METHODS

func _highlight_valid_tiles_in_radius(root_cell: Vector2i, radius: int):
	# iterate over all grid cells within a 3-cell radius 
	for x in range(root_cell.x - radius, root_cell.x + (radius + 1)):
		for y in range(root_cell.y - radius, root_cell.y + (radius + 1)):
			var tile_position = Vector2i(x, y)
			if !is_tile_position_valid(tile_position):
				continue
				
			# paint tiles in tilemap
			highlight_tile_map_layer.set_cell(tile_position, 0, Vector2i.ZERO)


func _on_building_placed(building_component: BuildingComponent):
	mark_tile_as_occupied(building_component.get_grid_cell_position())



	#var building_components: Array[BuildingComponent] = []
	#for node in get_tree().get_nodes_in_group("BuildingComponent"): #returns array of type Node
		 ## so need to cast each result as `BuildingComponent`
		#var component = node as BuildingComponent
		#if component:
			#building_components.append(component)
	
	# should by default clear the tilemap everytime it is called
