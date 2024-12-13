extends Node

@export var building_scene: PackedScene

@onready var gridManager: Node = $GridManager
@onready var cursor: Sprite2D = $Cursor
@onready var place_building_button: Button = $PlaceBuildingButton

var hovered_grid_cell: Vector2i = Vector2i(-1, -1)
var null_cell_value = Vector2(-10,-10)


func _ready() -> void:
	place_building_button.pressed.connect(on_button_pressed)
	cursor.visible = false


func _process(_delta: float) -> void:
	var grid_position = gridManager.get_mouse_grid_cell_position()
	# set the cursor to the mouse position
	cursor.global_position = grid_position * 64 
	
	if cursor.visible && (!hasValue(hovered_grid_cell) || hovered_grid_cell != grid_position):
		 # reassign the hovered_grid_cell
		hovered_grid_cell = grid_position
		gridManager.highlight_buildable_tiles()


func _unhandled_input(event: InputEvent) -> void:
	if (hasValue(hovered_grid_cell) && event.is_action_pressed("left_click") && gridManager.is_tile_position_buildable(hovered_grid_cell)):
		# place building
		place_building_at_hovered_cell_position()
		# hide cursor now that building has been placed
		cursor.visible = false



func place_building_at_hovered_cell_position():
	if !hasValue(hovered_grid_cell):
		return
	
	var building = building_scene.instantiate() as Node2D
	add_child(building)
	
	building.global_position = hovered_grid_cell * 64
	
	# reset the hover state and clear the tilemap to remove highlight cell after placing a building
	hovered_grid_cell = null_cell_value
	gridManager.clear_highlighted_tiles()


func on_button_pressed():
	cursor.visible = true


func hasValue(cell: Vector2) -> bool:
	if cell == null_cell_value:
		return false
	else:
		return true
