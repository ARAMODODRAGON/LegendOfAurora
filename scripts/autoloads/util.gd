extends Node
## Util class containing common constants / functionality

## groups

const WARP_POINT: StringName = &"warp_point"
const ROOM_OBJECTS: StringName = &"room_objects"

func get_warp_points() -> Array[Node]:
	return get_tree().get_nodes_in_group(WARP_POINT)

func get_room_objects() -> Array[Node]:
	return get_tree().get_nodes_in_group(ROOM_OBJECTS)

## group function names

# expects func _room_object_load(object_layer: Node) -> void
const ROOM_OBJECTS_LOAD_FUNC: StringName = &"_room_object_load"

# expects func _room_object_unload(object_layer: Node) -> void
const ROOM_OBJECTS_UNLOAD_FUNC: StringName = &"_room_object_unload"

## constants

const TILE_SIZE : Vector2 = Vector2(16.0, 16.0)
const SCREEN_SIZE : Vector2 = Vector2(256.0, 224.0)

const VERY_SMALL : float = 0.001

## functions

func equalf(a: float, b: float, epsilon: float = VERY_SMALL) -> bool:
	return abs(a - b) < epsilon

func equalv2(a: Vector2, b: Vector2, epsilon: float = VERY_SMALL) -> bool:
	return equalf(a.x, b.x, epsilon) && equalf(a.y, b.y, epsilon)

func nearest_point_within_rect(point: Vector2, rect: Rect2) -> Vector2:
	var new_point : Vector2
	new_point.x = clampf(point.x, rect.position.x, rect.end.x)
	new_point.y = clampf(point.y, rect.position.y, rect.end.y)
	return new_point
