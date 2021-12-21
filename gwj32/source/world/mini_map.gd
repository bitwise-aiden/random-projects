class_name MiniMap extends TileMap


# Constant variables
const FLOAT_EPSILON = 0.00001
const ROTATIONS_AS_TRANFORMATIONS: Dictionary = {
	PI * 0.0: [false, false, false],
	PI * 0.5: [true, false, true],
	PI * 1.0: [false, true, false],
	PI * -0.5: [false, false, true]
}

# Private variables
var __current: Vector2 = Vector2.ZERO
var __rooms: Dictionary = {
	# key: Vector2, position of the room
	# value: Room, reference to the room
}
var __room_offsets: Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]
onready var __start_position = self.position


# Lifecycle methods
func _ready():
	Globals.mini_map = self

	self.__generate_rooms()
	self.__render_rooms()

	Event.connect("room_complete", self, "__room_complete")


# Public methods
func current_room() -> Room:
	return self.__rooms[self.__current]


func can_move_to(offset: Vector2) -> bool:
	return self.__rooms[self.__current].adjacent.has(offset)


func move_to(offset: Vector2) -> Room:
	self.__current += offset

	var room: Room = self.current_room()

	room.visible = true
	self.__render_rooms()

	Event.emit_signal("room_changed", room, -offset)

	return room


# Private methods
func __generate_rooms() -> void:
	# Clear existing rooms
	self.__rooms.clear()

	# Genreate start and end point
	var destination = Vector2(randi() % 5, randi() % 5)
	var spawn = destination
	while destination.distance_to(spawn) < 2.3:
		spawn = Vector2(randi() % 5, randi() % 5)

	# Initialize the current room
	self.__current = spawn

	var adjacent = []

	# Create offsets needed to traverse from spawn to destination
	var direction_to_destination = spawn.direction_to(destination) * spawn.distance_to(destination)
	var path_to_start = []
	var x_movement = Vector2(direction_to_destination.x, 0.0).normalized()
	for x in abs(direction_to_destination.x):
		path_to_start.append(x_movement)

	var y_movement = Vector2(0.0, direction_to_destination.y).normalized()
	for y in abs(direction_to_destination.y):
		path_to_start.append(y_movement)

	# Create the end room
	self.__rooms[spawn] = Room.new(spawn, Room.Types.SPAWN, true, true)

	# Randomize the path taken from end to start, adding rooms for each
	var current: Vector2 = spawn
	path_to_start.shuffle()
	for offset in path_to_start:
		# Store the adjacent possibilities of the current room
		self.__add_adjancent(adjacent, current)
		var previous_room = self.__rooms[current]

		# Update the current room
		current += offset

		# Remove the current room from adjacent possibilities
		self.__remove_adjacent(adjacent, current)

		# Add room adjacency
		self.__rooms[current] = Room.new(current, Room.Types.PATH)
		self.__rooms[current].add_adjacent(previous_room)
		previous_room.add_adjacent(self.__rooms[current])

	# Update the destination room to have correct type
	self.__rooms[destination].type = Room.Types.DESTINATION

	# Generate 3 to 5 extra rooms adjacent to the current rooms
	for i in randi() % 3 + 3:
		# Pick room position, and remove it from adjacent possibilities
		var index = randi() % adjacent.size()
		var position: Vector2 = adjacent[index]
		adjacent.remove(index)

		# Create room
		self.__rooms[position] = Room.new(position, Room.Types.OTHER)

		# Randomly pick the adjacent room that it will attach to
		self.__room_offsets.shuffle()
		for offset in self.__room_offsets:
			var room_position: Vector2 = position + offset
			if self.__rooms.has(room_position):
				self.__rooms[position].add_adjacent(self.__rooms[room_position])
				self.__rooms[room_position].add_adjacent(self.__rooms[position])

				break

		# Store the adjacent possibilities of the current room
		self.__add_adjancent(adjacent, position)

	# Create offset and center on map
	var top_left = Vector2.INF
	var bottom_right = -Vector2.INF

	for position in self.__rooms:
		if position.x < top_left.x:
			top_left.x = position.x

		if position.x > bottom_right.x:
			bottom_right.x = position.x

		if position.y < top_left.y:
			top_left.y = position.y

		if position.y > bottom_right.y:
			bottom_right.y = position.y

	var bounds_center = (bottom_right - top_left) * 0.5 + top_left
	self.position = self.__start_position - bounds_center * 33

	Event.emit_signal("room_changed", self.current_room(), Vector2.ZERO)


func __render_rooms() -> void:
	# Clear existing rooms
	self.clear()

	var center_offset = Vector2.ONE * -2.0

	# Iterate over rooms, rendering their adjacency
	for position in self.__rooms:
		if !self.__rooms[position].visible:
			continue

		var room_position: Vector2 = (position + center_offset) * 3.0
		var room_current: int = int(position == self.__current) * 2

		for offset in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var display_position: Vector2 = room_position + offset
			var tile: int = int(self.__rooms[position].adjacent.has(offset)) + room_current
			var rotation: float = Vector2.UP.angle_to(offset)
			var transformation: Array = rotation_to_transformation(rotation)

			self.set_cellv(
				display_position,
				tile,
				transformation[0],
				transformation[1],
				transformation[2]
			)

		self.set_cellv(room_position, 4 + self.__rooms[position].type)


func __add_adjancent(adjacent: Array, position: Vector2) -> void:
	for offset in self.__room_offsets:
		var new_position = position + offset

		if self.__rooms.has(new_position):
			continue

		if max(new_position.x, new_position.y) == 5:
			continue

		if min(new_position.x, new_position.y) == -1:
			continue

		adjacent.append(new_position)


func __remove_adjacent(adjacent: Array, position: Vector2) -> void:
	var index = adjacent.find(position)
	if index != -1:
		adjacent.remove(index)


func __room_complete() -> void:
	self.current_room().complete = true


# Static methods
static func compare_floats(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon


static func rotation_to_transformation(rotation: float) -> Array:
	for value in ROTATIONS_AS_TRANFORMATIONS:
		if compare_floats(rotation, value):
			return ROTATIONS_AS_TRANFORMATIONS[value]

	return ROTATIONS_AS_TRANFORMATIONS[0.0]
