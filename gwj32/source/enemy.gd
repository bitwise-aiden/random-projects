class_name Enemy extends KinematicBody2D


onready var enemy = load("res://source/enemy.tscn")


# Instance variables
onready var __sprite: Sprite = $sprite
onready var __animation: AnimationPlayer = $animation
onready var next_jump: float = PhysicsTime.elapsed_time + randf() * 3.0

var moving: bool = false
var player_position: Vector2 = Vector2.ZERO
var size: float = 5.0
var health: int = 0.0


# Lifecycle methods
func _ready() -> void:
	self.scale = Vector2.ONE * self.size
	self.health = self.size


func _physics_process(_delta: float) -> void:
	if self.next_jump < PhysicsTime.elapsed_time:
		print(self.next_jump)
		print(PhysicsTime.elapsed_time)
		self.player_position = Globals.player.position

		self.scale.x = sign(self.player_position.x - self.position.x) * self.size

		self.__animation.play("New Anim")
		self.next_jump = PhysicsTime.elapsed_time + 2.0 * (self.size * (0.5 + randf() * 0.5))

	if self.moving:
		var new_position = self.position.move_toward(
			self.player_position,
			40.0 * PhysicsTime.delta_time * self.size
		)

		self.move_and_collide(new_position - self.position)


func start_move() -> void:
	self.moving = true


func end_move() -> void:
	self.moving = false


func destroy() -> void:
	self.call_deferred("queue_free")

	if self.size == 2:
		return

	var spawn_amount: int = randi() % 2 + 2
	var spawn_rotation: float = TAU / spawn_amount
	for i in spawn_amount:
		var instance = self.enemy.instance()
		instance.position = self.position + Vector2.RIGHT.rotated(spawn_rotation * i) * 10.0 * self.size
		instance.size = self.size - 1

		self.get_node("/root/main").call_deferred("add_child", instance)
