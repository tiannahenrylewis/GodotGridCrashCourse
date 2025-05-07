extends Node

@export var tower_resource: BuildingResource
@export var village_resource: BuildingResource

@onready var gridManager: Node = $GridManager
@onready var cursor: Sprite2D = $Cursor
@onready var y_sort_root: Node2D = $YSortRoot
@onready var game_ui = $GameUI

var hovered_grid_cell: Vector2i = Vector2i(-1, -1)
var null_cell_value = Vector2(-10,-10)
var to_place_building_resource: BuildingResource = null


func _ready() -> void:
	game_ui.place_tower_button.pressed.connect(on_place_tower_button_pressed)
	game_ui.place_village_button.pressed.connect(on_place_village_button_pressed)
	cursor.visible = false
	
	GameEvents.connect("resource_tiles_updated", on_resource_tiles_updated)


func _process(_delta: float) -> void:
	var grid_position = gridManager.get_mouse_grid_cell_position()
	# set the cursor to the mouse position
	cursor.global_position = grid_position * 64 
	
	if to_place_building_resource != null && cursor.visible && (!hasValue(hovered_grid_cell) || hovered_grid_cell != grid_position):
		 # reassign the hovered_grid_cell
		hovered_grid_cell = grid_position
		gridManager.clear_highlighted_tiles() # wiping the entire tileset
		gridManager.highlight_expanded_buildable_tiles(hovered_grid_cell, to_place_building_resource.buildable_radius)
		gridManager.highlight_resource_tiles(hovered_grid_cell, to_place_building_resource.resource_radius)


func _unhandled_input(event: InputEvent) -> void:
	if (hasValue(hovered_grid_cell) && event.is_action_pressed("left_click") && gridManager.is_tile_position_buildable(hovered_grid_cell)):
		# place building
		place_building_at_hovered_cell_position()
		# hide cursor now that building has been placed
		cursor.visible = false



func place_building_at_hovered_cell_position():
	if !hasValue(hovered_grid_cell):
		return
	
	var building = to_place_building_resource.building_scene.instantiate() as Node2D
	y_sort_root.add_child(building)
	
	building.global_position = hovered_grid_cell * 64
	
	# reset the hover state and clear the tilemap to remove highlight cell after placing a building
	hovered_grid_cell = null_cell_value
	gridManager.clear_highlighted_tiles()


func on_place_tower_button_pressed():
	to_place_building_resource = tower_resource
	cursor.visible = true
	gridManager.highlight_buildable_tiles()


func on_place_village_button_pressed():
	to_place_building_resource = village_resource
	cursor.visible = true
	gridManager.highlight_buildable_tiles()


func on_resource_tiles_updated(resource_count: int):
	print("Resource count: ", resource_count)


func hasValue(cell: Vector2) -> bool:
	if cell == null_cell_value:
		return false
	else:
		return true
