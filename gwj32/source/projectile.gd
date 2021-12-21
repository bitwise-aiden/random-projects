class_name Projectile extends KinematicBody2D


# Constant variables
var BASE_SPEED: float = 400.0


# Public variables
var direction: Vector2 = Vector2.ZERO
var damage: float = 0.0
var lifetime: float = 0.0


# Lifecycle methods
func _ready() -> void:
	# We do not want the projectile to spawn without a direction
	if self.direction == Vector2.ZERO:
		self.call_deferred("queue_free")
		return

	self.lifetime += PhysicsTime.elapsed_time


func _physics_process(delta: float) -> void:
	if self.lifetime < PhysicsTime.elapsed_time:
		self.call_deferred("queue_free")
		return

	var collision: KinematicCollision2D = self.move_and_collide(
		self.direction * self.BASE_SPEED * PhysicsTime.delta_time
	)

	if !collision:
		return

	if collision.collider is Enemy:
		collision.collider.destroy()

	self.call_deferred("queue_free")
