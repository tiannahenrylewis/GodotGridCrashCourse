# GridManager is responsible for keep tracking of all the tiles that are
# buildable (where buildings can be built), what buildings have been built and whire.
extends Node

@export var highlight_tile_map_layer: TileMapLayer 
@export var base_terrain_tile_map_layer: TileMapLayer

const IS_BUILDABLE: String = "is_buildable"
const IS_WOOD: String = "is_wood"

var all_tile_map_layers: Array[TileMapLayer] = []
var valid_buildable_tiles = {}
var collected_resource_tiles = {}
#OCCUPIED_CELLS &  CONVIENCENE METHODS
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
	all_tile_map_layers = _get_all_tile_map_layers(base_terrain_tile_map_layer)

# is a tile valid in principle
# perform a depth-first search to check for validity across different tile layers
func tile_has_custom_data(tile_position: Vector2i, data_name: String) -> bool:
	for layer in all_tile_map_layers:
		var customData = layer.get_cell_tile_data(tile_position)
		#If data is not available then return false
		if customData == null:
			continue
		#If the tile is not marked as `buildable` return false
		return customData.get_custom_data(data_name)
	return false


# is tile in a state where a building can be placed on it, in range of another building
# that extends the range of the buildable area
func is_tile_position_buildable(tile_position: Vector2i) -> bool:
	return valid_buildable_tiles.has(tile_position)


func highlight_buildable_tiles():
	for tile_position in valid_buildable_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, Vector2i.ZERO);


func highlight_expanded_buildable_tiles(root_cell: Vector2i, radius: int):
	highlight_buildable_tiles() # re-highlighting the tiles that are currently buildable
	
	# highlight the green tiles (expanded buildable tiles)
	# get all valid tiles in radius
	var valid_tiles = _get_valid_tiles_in_radius(root_cell, radius)
	# remove already existing buildable tiles
	var expanded_tiles = []
	var occupied_tiles = _get_occupied_tile_positions()
	var atlas_coordinates = Vector2i(1,0) # coordinates of the green cell in the highlight tileset
	for tile in valid_tiles:
		if not tile in valid_buildable_tiles and not tile in occupied_tiles:
			expanded_tiles.append(tile)
	for tile_position in expanded_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coordinates)


func highlight_resource_tiles(root_cell: Vector2i, radius: int):
	var resource_tiles = _get_valid_resource_tiles_in_radius(root_cell, radius)
	var atlas_coordinates = Vector2i(1,0) # coordinates of the green cell in the highlight tileset
	for tile_position in resource_tiles:
		highlight_tile_map_layer.set_cell(tile_position, 0, atlas_coordinates)


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

func _get_all_tile_map_layers(root_tile_map_layer: TileMapLayer) -> Array[TileMapLayer]:
	#print("*** Getting tile map layers for: " + root_tile_map_layer.name)
	var result: Array[TileMapLayer] = []
	#reverse the children of tile map layer so that the check is the right order
	var children = root_tile_map_layer.get_children()
	children.reverse()
	# iterate over each each child of tile map layer - returns an array of nodes
	for child in children:
		# check if the returned node from get_children() is in fact a TileMapLayer node
		if child is TileMapLayer:
			# recursive call to perform the same check on the child and add to the result array
			result.append_array(_get_all_tile_map_layers(child))
	#print("*** Adding tile map layer to result: " + root_tile_map_layer.name)
	result.append(root_tile_map_layer)
	#print("*** Result: ")
	#for item in result:
		#print("   " + item.name)
	return result

func _update_valid_buildable_tiles(building_component: BuildingComponent):
	var root_cell = building_component.get_grid_cell_position()
	# REMOVED BELOW BECAUSE A WARNING THAT IT WASN'T BEING USED
	# var radius = building_component.building_resource.buildable_radius
	
	# Admittedly the use of the call is a tad confusing this was implemented in 24. Highlighting Resources Tile
	var valid_tiles = _get_valid_tiles_in_radius(root_cell, building_component.building_resource.buildable_radius)
	# perform equivalent operation as using UnionWith in C#
	for tile in valid_tiles:
		valid_buildable_tiles[tile] = true
	
	# Iterate through and remove all 
	var occupied_tiles = _get_occupied_tile_positions()
	for existing_building_component in occupied_tiles:
		valid_buildable_tiles.erase(existing_building_component)


func _update_collected_resource_tiles(building_component: BuildingComponent):
	var root_cell = building_component.get_grid_cell_position()
	var resource_tiles = _get_valid_resource_tiles_in_radius(root_cell, building_component.building_resource.resource_radius)
	
	var oldResourceTileCount = collected_resource_tiles.size()
	
	# perform equivalent operation as using UnionWith in C#
	for tile in resource_tiles:
		collected_resource_tiles[tile] = true
	
	# only emit signal if count changes
	if (oldResourceTileCount != collected_resource_tiles.size()):
		# emit signal to notify the game 
		GameEvents.emit_resource_tiles_updated(collected_resource_tiles.size())


# a generic function that can be used with different filter functions to get the tiles desired
func _get_tiles_in_radius(root_cell: Vector2i, radius: int, filterFn: Callable) -> Array:
	var result = Array()
	# iterate over all grid cells within a 3-cell radius of the building component
	for x in range(root_cell.x - radius, root_cell.x + (radius + 1)):
		for y in range(root_cell.y - radius, root_cell.y + (radius + 1)):
			var tile_position = Vector2i(x, y)
			if !filterFn.call(tile_position):
				continue
				
			# add tiles to result array
			result.append(tile_position)
	return result

# Responsible for getting all tiles within a certain radius of a given cell that are valid
func _get_valid_tiles_in_radius(root_cell: Vector2i, radius: int) -> Array:
	return _get_tiles_in_radius(root_cell, radius, func(tile_position: Vector2i) -> bool: 
		return tile_has_custom_data(tile_position, IS_BUILDABLE)
	)

func _get_valid_resource_tiles_in_radius(root_cell: Vector2i, radius: int) -> Array:
	return _get_tiles_in_radius(root_cell, radius, func(tile_position: Vector2i) -> bool: 
		return tile_has_custom_data(tile_position, IS_WOOD)
	)

func _get_occupied_tile_positions() -> Array:
	var occupied_tile_positions = Array()
	var occupied_tiles = get_tree().get_nodes_in_group("BuildingComponent")
	for tile in occupied_tiles:
		occupied_tile_positions.append(tile.get_grid_cell_position())
	return occupied_tile_positions


func _on_building_placed(building_component: BuildingComponent):
	_update_valid_buildable_tiles(building_component)
	_update_collected_resource_tiles(building_component)


	#var building_components: Array[BuildingComponent] = []
	#for node in get_tree().get_nodes_in_group("BuildingComponent"): #returns array of type Node
		 ## so need to cast each result as `BuildingComponent`
		#var component = node as BuildingComponent
		#if component:
			#building_components.append(component)
	
	# should by default clear the tilemap everytime it is called
