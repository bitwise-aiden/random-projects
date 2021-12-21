extends KinematicBody2D


# Constant variables
const BASE_ATTACK_SPEED: float = 1.0
const BASE_DAMAGE: float = 1.0
const BASE_MOVEMENT_SPEED: float = 200.0
const BASE_RANGE: float = 0.5
const SPAWN_LOCTIONS: Dictionary = {
	Vector2.ZERO: Vector2(19, 11),
	Vector2.UP: Vector2(19, 4),
	Vector2.DOWN: Vector2(19, 18),
	Vector2.LEFT: Vector2(4, 11),
	Vector2.RIGHT: Vector2(35, 11),
}


# Instance variables
onready var projectile = preload("res://source/projectile.tscn")


# Private variables
var __next_fire_timestamp: float = 0.0
onready var __attack_speed: Stat = Stat.new("attack_speed", 0.6)
onready var __movement_speed: Stat = Stat.new("movement_speed", 200.0)
onready var __damage: Stat = Stat.new("damage", 5.0)
onready var __range: Stat = Stat.new("range", 1.0)


# Lifecycle methods
func _ready() -> void:
	Globals.player = self

	Event.connect("room_changed", self, "__room_changed")
	Event.connect("room_complete", self, "__room_complete")


func _physics_process(delta: float) -> void:
	var movement_direction: Vector2 = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	var movement_speed: float = self.BASE_MOVEMENT_SPEED + self.__movement_speed.value()
	self.move_and_slide(movement_direction * movement_speed, Vector2.UP)

	if self.__next_fire_timestamp > PhysicsTime.elapsed_time:
		return

	for i in self.get_slide_count():
		var collision: KinematicCollision2D = self.get_slide_collision(i)
		if collision.collider is Doors:
			var move_direction: Vector2 = -collision.normal
			if Globals.mini_map.can_move_to(move_direction):
				Globals.mini_map.move_to(move_direction)


	var fire_direction: Vector2 = Vector2(
		Input.get_action_strength("fire_right") - Input.get_action_strength("fire_left"),
		Input.get_action_strength("fire_down") - Input.get_action_strength("fire_up")
	).normalized()

	if fire_direction:
		var dot_between: float = movement_direction.dot(fire_direction)
		var player_velocity_strength: float = inverse_lerp(-1.0, 1.0, dot_between) * 2.0

		var instance: Projectile = self.projectile.instance()
		instance.direction = fire_direction
		instance.damage = self.BASE_DAMAGE + self.__damage.value()
		instance.position = self.position
		instance.lifetime = self.BASE_RANGE + self.__range.value()

#		if player_velocity_strength:
#			instance.movement_offset = movement_direction * self.BASE_SPEED * 1.5

		self.get_node("/root/main").call_deferred("add_child", instance)
		var attack_speed: float = self.BASE_ATTACK_SPEED - self.__attack_speed.value()
		self.__next_fire_timestamp = PhysicsTime.elapsed_time + attack_speed


# Private methods
func __room_changed(room: Room, transition_from: Vector2) -> void:
	self.position = self.SPAWN_LOCTIONS[transition_from] * 32.0


func __room_complete() -> void:
	match randi() % 6:
		1:
			self.__damage.increment()
		2:
			self.__attack_speed.increment()
		3:
			self.__range.increment()
		4:
			self.__movement_speed.increment()
		5:
			self.__damage.increment()
			self.__attack_speed.increment()
			self.__range.increment()
			self.__movement_speed.increment()
