class_name BuildingResource # Makes this a global class which can be created from the editor
extends Resource

@export var display_name: String
@export var resource_cost: int
@export var buildable_radius: int
@export var resource_radius: int
@export var building_scene: PackedScene
@export var sprite_scene: PackedScene





# Custom resources allows to create a text file that can be used
# Good for when there is data that wants to be configurable
