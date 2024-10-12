extends Node2D

@export var building_scene: PackedScene

@onready var cursor: Sprite2D = $Cursor
@onready var place_building_button: Button = $PlaceBuildingButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_building_button.pressed.connect(on_button_pressed)
	cursor.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var grid_position = get_mouse_grid_cell_position()
	# set the cursor to the mouse position
	cursor.global_position = grid_position * 64 


func _unhandled_input(event: InputEvent) -> void:
	if (cursor.visible && event.is_action_pressed("left_click")):
		# place building
		place_building_at_mouse_position()
		# hide cursor now that building has been placed
		cursor.visible = false


func get_mouse_grid_cell_position() -> Vector2:
	# get mouse position -> returns Vector2(x,y)
	var mouse_position = get_global_mouse_position()
	# divide x and y by 64
	var grid_position = mouse_position / 64
	# round down the grid position
	grid_position = grid_position.floor() 
	return grid_position


func place_building_at_mouse_position():
	var building = building_scene.instantiate() as Node2D
	add_child(building)
	var grid_position = get_mouse_grid_cell_position()
	building.global_position = grid_position * 64


func on_button_pressed():
	cursor.visible = true
