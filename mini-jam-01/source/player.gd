extends Node2D

# Enums 
enum States { MOVING = 0, REWINDING, REPLAYING }

# Constants
const SPEED = 50.0

# Member variables
var __buffer: Dictionary = {
	# Key: timestamp / elapsed time
	# Value: position
}
var __buffer_timestamps: Array = []
var __current_velocity: Vector2 = Vector2.ZERO
var __position_prev: Vector2 = Vector2.INF
var __position_next: Vector2 = Vector2.INF
var __state: int = States.MOVING


# Life cylce methods
func _ready() -> void:
	Time.elapsed_time = 0.0
	self.__buffer[Time.elapsed_time] = self.position


func _process(delta: float) -> void:
	match self.__state:
		States.MOVING:
			self.__handle_input()
		States.REWINDING: 
			self.__handle_rewinding()


# Private methods
func __handle_input() -> void:
	var velocity: Vector2 = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if velocity != self.__current_velocity:
		self.__buffer[Time.elapsed_time] = self.position
		self.__current_velocity = velocity

	if !self.__buffer.empty() && Input.is_action_just_pressed("replay"):
		Globals.time_modifier = -2.0
		self.__state = States.REWINDING
		self.__buffer[Time.elapsed_time] = self.position
		
		self.__buffer_timestamps = self.__buffer.keys()
		self.__buffer_timestamps.invert()
	
	self.position += self.__current_velocity * self.SPEED * Time.delta_time


func __handle_rewinding() -> void:
	if self.__buffer_timestamps.size() == 1:
		Globals.time_modifier = 1.0
		self.__state = States.MOVING
		self.position = self.__buffer[self.__buffer_timestamps[0]]
		self.__buffer = {
			0.0: self.position
		}
		return 	
		
	var start = self.__buffer_timestamps[0]
	var end = self.__buffer_timestamps[1]
	
	var position_start = self.__buffer[start]
	var position_end = self.__buffer[end]
	
	var interval = start - end
	var elapsed = start - Time.elapsed_time
	
	var value = elapsed / interval
	var clamped_value = clamp(value, 0.0, 1.0)
	self.position = lerp(position_start, position_end, clamped_value)
	
	# TODO: wear our remaining value instead of adding it to the previous time elapsed
	
	if Time.elapsed_time < end:
		Time.elapsed_time_previous += end - Time.elapsed_time
		self.__buffer_timestamps.pop_front()
	
