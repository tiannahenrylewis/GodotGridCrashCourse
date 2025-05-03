extends Node

@export var tower_scene: PackedScene
@export var village_scene: PackedScene

@onready var gridManager: Node = $GridManager
@onready var cursor: Sprite2D = $Cursor
@onready var place_tower_button: Button = $PlaceTowerButton
@onready var place_village_button: Button = $PlaceVillageButton
@onready var y_sort_root: Node2D = $YSortRoot

var hovered_grid_cell: Vector2i = Vector2i(-1, -1)
var null_cell_value = Vector2(-10,-10)
var to_place_building: PackedScene = null


func _ready() -> void:
	place_tower_button.pressed.connect(on_place_tower_button_pressed)
	place_village_button.pressed.connect(on_place_village_button_pressed)
	cursor.visible = false


func _process(_delta: float) -> void:
	var grid_position = gridManager.get_mouse_grid_cell_position()
	# set the cursor to the mouse position
	cursor.global_position = grid_position * 64 
	
	if cursor.visible && (!hasValue(hovered_grid_cell) || hovered_grid_cell != grid_position):
		 # reassign the hovered_grid_cell
		hovered_grid_cell = grid_position
		gridManager.highlight_expanded_buildable_tiles(hovered_grid_cell, 3)


func _unhandled_input(event: InputEvent) -> void:
	if (hasValue(hovered_grid_cell) && event.is_action_pressed("left_click") && gridManager.is_tile_position_buildable(hovered_grid_cell)):
		# place building
		place_building_at_hovered_cell_position()
		# hide cursor now that building has been placed
		cursor.visible = false



func place_building_at_hovered_cell_position():
	if !hasValue(hovered_grid_cell):
		return
	
	var building = to_place_building.instantiate() as Node2D
	y_sort_root.add_child(building)
	
	building.global_position = hovered_grid_cell * 64
	
	# reset the hover state and clear the tilemap to remove highlight cell after placing a building
	hovered_grid_cell = null_cell_value
	gridManager.clear_highlighted_tiles()


func on_place_tower_button_pressed():
	to_place_building = tower_scene
	cursor.visible = true
	gridManager.highlight_buildable_tiles()


func on_place_village_button_pressed():
	to_place_building = village_scene
	cursor.visible = true
	gridManager.highlight_buildable_tiles()


func hasValue(cell: Vector2) -> bool:
	if cell == null_cell_value:
		return false
	else:
		return true
