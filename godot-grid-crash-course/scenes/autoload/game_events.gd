extends Node

signal building_resource_selected_signal(building_resource: BuildingResource)
signal building_placed_signal(building_component: BuildingComponent)
signal building_destroyed_signal(building_component: BuildingComponent)
signal resource_tiles_updated(collected_tiles: int)


func emit_building_resource_selected_signal(building_resource: BuildingResource):
	emit_signal("building_resource_selected_signal", building_resource)


func emit_building_placed(building_component: BuildingComponent):
	emit_signal("building_placed_signal", building_component)


func emit_building_destroyed(building_component: BuildingComponent):
	emit_signal("building_destroyed_signal", building_component)


func emit_resource_tiles_updated(collected_tiles: int):
	emit_signal("resource_tiles_updated", collected_tiles)
