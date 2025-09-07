class_name Enum

enum Direction {
	NONE = -1,
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

static func vector_from_direction(direction: Direction) -> Vector2:
	match direction:
		Direction.LEFT:
			return Vector2.LEFT
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.NONE, _:
			return Vector2.ZERO