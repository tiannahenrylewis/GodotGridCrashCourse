extends MarginContainer

@onready var hbox_container: HBoxContainer = $HBoxContainer

@export var building_resources: Array[BuildingResource]

func _ready():
	create_building_buttons()
	

func create_building_buttons():
	for building_resource in building_resources:
		# create an orphan node (not attached to scene tree)
		var buildingButton = Button.new()
		buildingButton.text = "Place {resource_name}".format({
			"resource_name": building_resource.display_name
		})
		# unorphan the node by adding to the scene tree
		hbox_container.add_child(buildingButton)
		#
		buildingButton.pressed.connect(func():
			GameEvents.emit_building_resource_selected_signal(building_resource)
		)
