extends Node

@export var building_scene: PackedScene

@onready var cursor: Sprite2D = $Cursor
@onready var place_building_button: Button = $PlaceBuildingButton
@onready var highlight_tile_map_layer: TileMapLayer = $HighlightTileMapLayer

var hovered_grid_cell: Vector2 = Vector2(-1, -1)
var null_cell_value = Vector2(-10,-10)

var occupied_cells = {}

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
	place_building_button.pressed.connect(on_button_pressed)
	cursor.visible = false


func _process(delta: float) -> void:
	var grid_position = get_mouse_grid_cell_position()
	# set the cursor to the mouse position
	cursor.global_position = grid_position * 64 
	
	if cursor.visible && (!hasValue(hovered_grid_cell) || hovered_grid_cell != grid_position):
		 # reassign the hovered_grid_cell
		hovered_grid_cell = grid_position
		update_highlight_tilemap_layer()


func _unhandled_input(event: InputEvent) -> void:
	if (hasValue(hovered_grid_cell) && event.is_action_pressed("left_click") && !occupied_cells.has(hovered_grid_cell)):
		# place building
		place_building_at_hovered_cell_position()
		# hide cursor now that building has been placed
		cursor.visible = false


func get_mouse_grid_cell_position() -> Vector2:
	# get mouse position -> returns Vector2(x,y)
	var mouse_position = highlight_tile_map_layer.get_global_mouse_position()
	# divide x and y by 64
	var grid_position = mouse_position / 64
	# round down the grid position
	grid_position = grid_position.floor() 
	return grid_position


func place_building_at_hovered_cell_position():
	if !hasValue(hovered_grid_cell):
		return
	
	var building = building_scene.instantiate() as Node2D
	add_child(building)
	
	building.global_position = hovered_grid_cell * 64
	# Add the grid position to the set of occupied cell
	occupied_cells[hovered_grid_cell] = true
	
	# reset the hover state and clear the tilemap to remove highlight cell after placing a building
	hovered_grid_cell = null_cell_value
	update_highlight_tilemap_layer()


func update_highlight_tilemap_layer():
	# should by default clear the tilemap everytime it is called
	highlight_tile_map_layer.clear()
	
	if !hasValue(hovered_grid_cell):
		return
		
	# iterate over all grid cells within a 3-cell radius 
	for x in range(hovered_grid_cell.x - 3, hovered_grid_cell.x + 4):
		for y in range(hovered_grid_cell.y - 3, hovered_grid_cell.y + 4):
			# paint tiles in tilemap
			highlight_tile_map_layer.set_cell(Vector2(int(x), int(y)), 0, Vector2i.ZERO)

func on_button_pressed():
	cursor.visible = true


func hasValue(cell: Vector2) -> bool:
	if cell == null_cell_value:
		return false
	else:
		return true
