class_name StateComponent
extends Node

var is_active: bool:
	get:
		return _is_active

var _is_active: bool

signal state_entered(last_state: StateComponent) 
signal state_exited(next_state: StateComponent)

signal process_state(delta: float)
signal physics_process_state(delta: float)
