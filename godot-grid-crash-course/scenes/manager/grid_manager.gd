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
	pass # Replace with function body.


func mark_tile_as_occupied(tile_position: Vector2):
	occupied_cells[tile_position] = true


func is_tile_position_valid(tile_position: Vector2) -> bool:
	return !occupied_cells.has(tile_position)


func highlight_valid_tiles_in_radius(root_cell: Vector2, radius: int):
	# should by default clear the tilemap everytime it is called
	clear_highlighted_tiles()
		
	# iterate over all grid cells within a 3-cell radius 
	for x in range(root_cell.x - radius, root_cell.x + (radius + 1)):
		for y in range(root_cell.y - radius, root_cell.y + (radius + 1)):
			if !is_tile_position_valid(Vector2(x, y)):
				continue
				
			# paint tiles in tilemap
			highlight_tile_map_layer.set_cell(Vector2(int(x), int(y)), 0, Vector2i.ZERO)


func clear_highlighted_tiles() :
	highlight_tile_map_layer.clear()


func get_mouse_grid_cell_position() -> Vector2:
	# get mouse position -> returns Vector2(x,y)
	var mouse_position = highlight_tile_map_layer.get_global_mouse_position()
	# divide x and y by 64
	var grid_position = mouse_position / 64
	# round down the grid position
	grid_position = grid_position.floor() 
	return grid_position
