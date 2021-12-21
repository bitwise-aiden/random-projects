class_name Level


# Public variables
var center: Vector2 = Vector2.ZERO
var size: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO


# Private variables
var __bounds: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)


# Lifecycle Method
func _init(position: Vector2, size: Vector2) -> void:
	self.__bounds = Rect2(position, size)
	self.center = position + size * 0.5
	self.size = size
	self.position = position


# Public methods
func has_entity(entity: EntityController) -> bool:
	return self.has_position(entity.position)


func has_position(position: Vector2) -> bool:
	return self.__bounds.has_point(position)
