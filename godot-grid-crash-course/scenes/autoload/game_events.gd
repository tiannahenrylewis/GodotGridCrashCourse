extends Node

signal building_placed_signal(building_component: BuildingComponent)
signal resource_tiles_updated(collected_tiles: int)

func emit_building_placed(building_component: BuildingComponent):
	print("Emitting `building_placed_signal`...")
	emit_signal("building_placed_signal", building_component)
	print("Emitted `building_placed_signal`.")

func emit_resource_tiles_updated(collected_tiles: int):
	print("Emitting `resource_tiles_updated`...")
	emit_signal("resource_tiles_updated", collected_tiles)
	print("Emitted `resource_tiles_updated`.")
