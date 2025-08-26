extends Node
class_name TestGenMap

@export_category("Structure Scenes")
@export var generic_structures: Array[PackedScene]

@onready var _objects: Node2D = $Structures

func _ready() -> void:
	var generator := StructureSparseGenerator.new()

	generator.structure_count = randi_range(10, 100)
	generator.structures = generic_structures

	generator.min_spacing = 0.0
	generator.max_spacing = 100.0

	generator.generate(_objects)
