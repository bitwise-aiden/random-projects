class_name PlayerController extends EntityController


# Constant variables
const OFFSET_MAP: Dictionary = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}


# Lifecycle methods
func _init(position: Vector2).(position) -> void:
	self.tile_id = 0


# Public methods
func move(position) -> void:
	self.position = position

func update() -> void:
	for input in self.OFFSET_MAP.keys():
		if Input.is_action_just_pressed(input):
			self.emit_signal("move", self.position + self.OFFSET_MAP[input])
