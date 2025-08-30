@icon("res://icons/Heart.svg")
extends Node
class_name HealthComponent

signal die()

@export var max_health: int = 1

var health: int = 0

func _ready() -> void:
	health = max_health

func _take_damage(damage: int) -> void:
	health = max(0, health - damage)

	if health == 0:
		die.emit()