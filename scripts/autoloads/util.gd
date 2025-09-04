extends Node
## Util class containing common constants / functionality

enum Direction {
	NONE,
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

const TILE_SIZE : Vector2 = Vector2(16.0, 16.0)
const SCREEN_SIZE : Vector2 = Vector2(256.0, 224.0)

const VERY_SMALL : float = 0.001

func equalf(a: float, b: float, epsilon: float = VERY_SMALL) -> bool:
	return abs(a - b) < epsilon

func equalv2(a: Vector2, b: Vector2, epsilon: float = VERY_SMALL) -> bool:
	return equalf(a.x, b.x, epsilon) && equalf(a.y, b.y, epsilon)

func nearest_point_within_rect(point: Vector2, rect: Rect2) -> Vector2:
	var new_point : Vector2
	new_point.x = clampf(point.x, rect.position.x, rect.end.x)
	new_point.y = clampf(point.y, rect.position.y, rect.end.y)
	return new_point
