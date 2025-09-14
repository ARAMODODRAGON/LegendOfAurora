class_name StatemachineComponent
extends Node

## constants

const INVALID_STATE: StringName = &"INVALID_STATE"


## exports

@export var initial_state: StateComponent


## public variables

## the name of the active state
var active_state: StringName:
	get:
		if _active_state:
			return _active_state.name
		else:
			return INVALID_STATE
	set(value):
		set_active_state(value)

## the active state component
var active_state_component: StateComponent:
	get:
		return _active_state


## private variables

var _statelist: Array[StateComponent] = []
var _active_state: StateComponent = null

## public methods

## gets the state, returns null if no matching state exists
func get_state_component(name_: StringName) -> StateComponent:
	var index := _statelist.find_custom(
		func(state: StateComponent) -> bool:
			if state.name == name_:
				return true
			else:
				return false
	)

	if index != -1:
		return _statelist[index]
	else:
		return null


## sets the active state, returns true on success
func set_active_state(name_: StringName) -> bool:
	var state := get_state_component(name_)

	if state == null:
		printerr("State \"" + name_ + "\" was not valid")
		return false
	
	return set_active_state_component(state)


## sets the active state using the component reference, returns true on success
func set_active_state_component(state: StateComponent) -> bool:
	if state == _active_state:
		return true
	
	if state.get_parent() != self:
		printerr("Could not set state as its not attached to this statemachine")
		return false
	
	if _active_state:
		_active_state.state_exited.emit(state)
		_active_state._is_active = false
		#print("state ", _active_state.name, " exited")

	_active_state = state

	if _active_state:
		_active_state.state_entered.emit(state)
		_active_state._is_active = true
		#print("state ", _active_state.name, " entered")
	
	return true

	
## private methods

func _ready() -> void:
	for child in get_children():
		var state := child as StateComponent
		if state:
			_statelist.push_back(state)
	
	if initial_state:
		set_active_state_component(initial_state)
	
	if _active_state == null and _statelist.size() > 0:
		set_active_state_component(_statelist[0])