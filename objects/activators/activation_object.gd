class_name ActivationObject
extends Node2D

const TriggerState := Enum.TriggerState
signal on_state_change(state: TriggerState)


## private
var _state : TriggerState


## virtual functions
func _on_triggered_on() -> void: pass
func _on_triggered_off() -> void: pass


## public
func get_state() -> TriggerState:
	return _state


## private
func _update_state(state: TriggerState) -> void:
	if _state != state:
		_state = state

		if _state:
			_on_triggered_on()
		else:
			_on_triggered_off()
		
		on_state_change.emit(state)