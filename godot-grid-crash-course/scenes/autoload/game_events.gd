extends Node

signal place_tower_button_pressed_signal
signal place_village_button_pressed_signal
signal building_placed_signal(building_component: BuildingComponent)
signal resource_tiles_updated(collected_tiles: int)

func emit_place_tower_button_pressed():
	emit_signal("place_tower_button_pressed_signal")


func emit_place_village_button_pressed():
	emit_signal("place_village_button_pressed_signal")


func emit_building_placed(building_component: BuildingComponent):
	emit_signal("building_placed_signal", building_component)


func emit_resource_tiles_updated(collected_tiles: int):
	emit_signal("resource_tiles_updated", collected_tiles)
