class_name Stat


# Constant variables
const VALUE_MAX: int = 10
const VALUE_MIN: int = 1

# Private variables
var __name: String = ""
var __step: float = 0
var __value: int = VALUE_MIN

# Lifecycle methods
func _init(name: String, value_range: float) -> void:
	self.__name = name
	self.__step = value_range / VALUE_MAX

	Event.emit_signal("stat_changed", self.__name, self.__value)


# Public methods
func increment() -> void:
	self.__change_value(1)


func decrement() -> void:
	self.__change_value(-1)


func value() -> float:
	return self.__value * self.__step


# Private methods
func __change_value(amount: int) -> void:
	self.__value = clamp(self.__value + amount, self.VALUE_MIN, self.VALUE_MAX)
	Event.emit_signal("stat_changed", self.__name, self.__value)

