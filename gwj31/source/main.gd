extends Node2D


# Instance variables
onready var __camera: Camera2D = $camera
onready var __map_collisions: TileMap = $map_collisions
onready var __map_entities: TileMap = $map_entities


# Private variables
var __current_level: Level = null
var __entities: Array = []
var __player: PlayerController = null


# Lifecycle methods
func _ready():
	self.__start()


func _process(_delta: float) -> void:
	if !self.__player:
		return

	self.__player.update()
	self.__draw()


# Private methods
func __center_camera_on_entity(entity: EntityController, pan: float = 2.5) -> void:
	if self.__current_level.has_entity(entity):
		self.__center_camera_on_level(self.__current_level, 5.0)
	else:
		self.__center_camera_on_position(entity.position, pan)


func __center_camera_on_position(position: Vector2, pan: float = 2.5) -> void:
	if pan:
		self.__camera.position = self.__camera.position.move_toward(
			self.w2s(position), pan
		)
	else:
		self.__camera.position = self.w2s(position)


func __center_camera_on_level(level: Level, pan: float = 2.5) -> void:
	self.__center_camera_on_position(level.center, pan)


func __check_collision(position: Vector2) -> bool:
	return self.__map_collisions.get_cellv(position) != TileMap.INVALID_CELL


func __draw() -> void:
	self.__center_camera_on_entity(self.__player, true)

	self.__map_entities.clear()

	for entity in self.__entities:
		self.__map_entities.set_cellv(entity.position, entity.tile_id)



func __entity_move(position: Vector2, entity: EntityController) -> void:
	if self.__check_collision(position):
		return

	entity.move(position)


func __entity_spawn(type: int, position: Vector2) -> void:
	var entity: EntityController

	match type:
		Entity.PLAYER:
			entity = PlayerController.new(position)
			self.__player = entity

	entity.connect("move", self, "__entity_move", [entity])

	self.__entities.append(entity)


func __start() -> void:
	self.__current_level = Level.new(
		Vector2(-20, -15),
		Vector2(40, 30)
	)

	self.__entity_spawn(Entity.PLAYER, Vector2(0, 0))


# Helper functions

# s2w: Converts the Vector2 from screen space to world space
func s2w(value: Vector2) -> Vector2:
	return (value - Vector2(8.0, 8.0)) / 16.0


# w2s: Converts the Vector2 from world space to screen space
func w2s(value: Vector2) -> Vector2:
	return value * 16.0 + Vector2(8.0, 8.0)
