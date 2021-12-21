extends TileMap

# Constant variables
const STAT_POSITIONS = {
	"attack_speed": Vector2(31, 0),
	"movement_speed": Vector2(31, 1),
	"damage": Vector2(11, 0),
	"range": Vector2(11, 1),
}


# Lifecycle methods
func _ready():
	Event.connect("stat_changed", self, "__stat_changed")


# Private methods
func __stat_changed(name: String, value: int) -> void:
	for i in 10:
		var tile: int = i < value
		var position: Vector2 = self.STAT_POSITIONS[name]
		self.set_cell(position.x + i, position.y, tile)
