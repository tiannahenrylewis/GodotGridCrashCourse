extends MarginContainer

@onready var place_tower_button: Button = %PlaceTowerButton
@onready var place_village_button: Button = %PlaceVillageButton

func _ready():
	place_tower_button.pressed.connect(on_place_tower_button_pressed)
	place_village_button.pressed.connect(on_place_village_button_pressed)

func on_place_tower_button_pressed():
	GameEvents.emit_place_tower_button_pressed()


func on_place_village_button_pressed():
	emit_signal("place_village_button_pressed")
