extends Node

signal building_placed_signal(building_component: BuildingComponent)

func emit_building_placed(building_component: BuildingComponent):
	print("Emitting `building_placed_signal`...")
	emit_signal("building_placed_signal", building_component)
	print("Emitted `building_placed_signal`.")
