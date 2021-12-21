class_name Room


# Enums
enum Types { DESTINATION = 0, SPAWN, PATH, OTHER }


# Public variables
var adjacent: Dictionary = {
	# key: Vector2, offset position from current to next room
	# value: Room, reference to the next room
}
var complete: bool = false
var position: Vector2 = Vector2.ZERO
var type: int = Types.OTHER
var visible: bool = false


# Lifecycle methods
func _init(position: Vector2, type: int, visible: bool = false, complete: bool = false) -> void:
	self.complete = complete
	self.position = position
	self.type = type
	self.visible = visible


# Public methods
func add_adjacent(room: Room) -> void:
	var offset: Vector2 = self.position.direction_to(room.position)
	self.adjacent[offset] = room


func set_visible(visible: bool) -> void:
	self.visible = visible
