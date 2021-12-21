class_name Doors extends TileMap


# Constant variables
const DOOR_LOCATIONS: Dictionary = {
	Vector2.UP: Vector2(19, 2),
	Vector2.DOWN: Vector2(19, 20),
	Vector2.LEFT: Vector2(2, 11),
	Vector2.RIGHT: Vector2(37, 11)
}


# Lifecycle methods
func _ready() -> void:
	Event.connect("room_changed", self, "__room_changed")


# Private methods
func __room_changed(room: Room, _transition_from: Vector2) -> void:
	for location in self.DOOR_LOCATIONS:
		var tile: int = int(!room.adjacent.has(location))
		self.set_cellv(self.DOOR_LOCATIONS[location], tile)

