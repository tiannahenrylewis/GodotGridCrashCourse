extends Node2D

@export var active_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	pass


func set_active():
	sprite.texture = active_texture
