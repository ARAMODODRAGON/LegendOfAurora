extends Node2D
class_name Structurebase

var size: Vector2:
	get: return _get_effective_size_rect().size

var center: Vector2:
	get: return position + (size * 0.5)
	set(value): position = value - (size * 0.5)

var radius: float:
	get: return (_get_effective_size_rect().size * 0.5).length()

var _effective_size_rect: ReferenceRect

func _get_effective_size_rect() -> ReferenceRect:
	if _effective_size_rect:
		return _effective_size_rect
	_effective_size_rect = $EffectiveSize
	return _effective_size_rect
