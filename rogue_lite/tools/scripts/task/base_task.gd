class_name BaseTask


var _completed: bool = false


func is_completed() -> bool:
	return self._completed


func update( detla: float ) -> void:
	self._completed = true 
