class_name EntityController

signal move(position)


# Public variable
var position: Vector2 = Vector2.ZERO
var tile_id: int = 0


# Lifecycle methods
func _init(position: Vector2) -> void:
	self.position = position


func update() -> void:
	pass
