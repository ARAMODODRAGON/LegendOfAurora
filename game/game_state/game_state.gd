## GameState autoload
extends Node


signal update_ui(state: LevelState)


## class used to represent one time unlocks
class UnlockState extends RefCounted:
	var _is_unlocked: bool = false


	func _init(is_unlocked_: bool = false) -> void:
		_is_unlocked = is_unlocked_

	func is_unlocked() -> bool:
		return _is_unlocked


	func unlock() -> void:
		_is_unlocked = true

	
## state stored for the specific level
class LevelState extends RefCounted:

	var _key_count: int = 0
	var _unlocks: Dictionary[StringName, UnlockState] = {}

	func get_key_count() -> int:
		return _key_count
	

	func add_key() -> void:
		_key_count += 1
		GameState.update_ui.emit(self)
	

	func use_key() -> bool:
		if _key_count <= 0:
			return false
		else:
			_key_count -= 1
			GameState.update_ui.emit(self)
			return true
	
	func is_unlocked(name: StringName) -> bool:
		var unlockstate := _unlocks[name]
		if unlockstate == null:
			return false
		else:
			return unlockstate.is_unlocked()
	
	func unlock(name: StringName) -> void:
		_unlocks[name] = UnlockState.new(true)



## static one time unlocks

# player mechanics
var white_sword_unlock := UnlockState.new()
var bongo_unlock := UnlockState.new()


## private variables

## dictionary of dynamic one time unlocks
var _dynamic_unlocks: Dictionary[StringName, UnlockState] = {}

## TODO: change this with a dict that stores a seperate state for each level
var _level_state: LevelState = LevelState.new()


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


## gets the level state
func level_state() -> LevelState:
	return _level_state