## GameState autoload
extends Node

## class used to represent one time unlocks
class UnlockState extends RefCounted:
	var _is_unlocked: bool = false


	func is_unlocked() -> bool:
		return _is_unlocked


	func unlock() -> void:
		_is_unlocked = true

	

## static one time unlocks

# player mechanics
var white_sword_unlock := UnlockState.new()
var bongo_unlock := UnlockState.new()


## dictionary of dynamic one time unlocks
var _dynamic_unlocks: Dictionary[StringName, UnlockState] = {}


## check dynamic unlocks
func is_unlocked(name_: StringName) -> bool:
	var unlock_state := _dynamic_unlocks[name_]
	if unlock_state != null:
		return unlock_state.is_unlocked()
	return false


## unlocking dynamic unlocks
func unlock(name_: StringName) -> void:
	var unlock_state := UnlockState.new()
	unlock_state.unlock()
	_dynamic_unlocks[name_] = unlock_state