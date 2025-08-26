extends RefCounted
class_name StructureSparseGenerator

## initialize these before calling .generate()
var min_spacing: float = 50.0
var max_spacing: float = 5000.0
var structure_count: int = 10
var structures: Array[PackedScene]

var _last_position: Vector2
var _last_structure_radius: float
var _generated: Array[Structurebase]
var _first_gen: bool

func generate(attach_to: Node) -> bool:
	if attach_to == null: return false
	if structures.size() == 0: return false

	_last_position = Vector2.ZERO
	_last_structure_radius = Util.SCREEN_SIZE.length()
	_generated = []
	_first_gen = false

	for i in structure_count:
		var packed_structure: PackedScene = structures[randi() % structures.size()]
		var structure: Structurebase = packed_structure.instantiate() as Structurebase

		if structure:
			_spawn_structure(structure)
	
	for s in _generated:
		attach_to.add_child(s)

	print("generated [" + str(_generated.size()) + "] structures:")
	for s in _generated:
		print("structure named \"" + s.name + "\" at position " + str(s.position))

	return true

	
func _get_random_direction(length: float = 1.0) -> Vector2:
	return Vector2.from_angle(randf_range(0.0, PI * 2.0)) * length

func _check_position(new_position: Vector2, radius: float) -> bool:
	if new_position.length() < (Util.SCREEN_SIZE.length() + radius):
		return false

	for s in _generated:
		if (s.center - new_position).length() < (radius + s.radius):
			return false 
	
	return true

func _get_rand_position_from_structure() -> Vector2:
	if _generated.size() > 0:
		var index := randi_range(0, _generated.size())
		if index == _generated.size():
			return Vector2.ZERO
		return _generated[index].center
	return Vector2.ZERO

func _spawn_structure(structure: Structurebase, tries: int = 70) -> void:
	for try in tries:
		var from_position := _get_rand_position_from_structure()
		
		var dir: Vector2 = _get_random_direction()
		var new_position: Vector2 = from_position + (dir * _last_structure_radius) + (dir * randf_range(min_spacing, max_spacing)) + (dir * structure.radius)
		
		print("try " + str(try) + " at " + str(new_position))

		if _check_position(new_position, structure.radius):
			structure.center = new_position
			_generated.push_back(structure)

			_last_position = new_position
			_last_structure_radius = structure.radius

			return
		
		
