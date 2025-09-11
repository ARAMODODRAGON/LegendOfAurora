class_name Enum

## boolean equivalent
enum TriggerState {
	ON = 1,
	OFF = 0,
}

enum Direction {
	NONE = -1,
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

static func direction_from_vector(direction: Vector2) -> Direction:
	if direction.length_squared() < Util.VERY_SMALL:
		return Direction.NONE

	var rotation: float = rad_to_deg(direction.angle())

	if rotation < 0.0:
		rotation += 360.0

	if rotation > 45.0 and rotation <= 135.0:
		return Direction.DOWN
	elif rotation > 135.0 and rotation <= 225.0:
		return Direction.LEFT
	elif rotation > 225.0 and rotation <= 315.0:
		return Direction.UP
	else:
		return Direction.RIGHT

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

static func flip_direction(direction: Direction) -> Direction:
	match direction:
		Direction.LEFT:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.LEFT
		Direction.UP:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.UP
		Direction.NONE, _:
			return Direction.NONE
