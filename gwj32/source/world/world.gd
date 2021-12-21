extends TileMap


# Private variables
var __entity_count: int = 0


# Lifecycle methods
func _ready() -> void:
	Event.connect("room_changed", self, "__room_changed")


# Private methods
func __room_changed(room: Room, _transition_from: Vector2) -> void:
	if room.complete:
		return

	# Randomize enemies
	self.__entity_count = 0

	self.__check_enemy_count()


func __check_enemy_count() -> void:
	if self.get_tree().get_nodes_in_group("enemy").size() == 0:
		Event.emit_signal("room_complete")
