class_name Hitbox
extends Area2D

var _effects : Array[HitEffect] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	for child in get_children():
		if child is HitEffect:
			_effects.push_back(child as HitEffect)


func _on_area_entered(area: Area2D) -> void:
	var target := area as Hitbox
	if target:
		for effect in _effects:
			effect._trigger(self, target)

func _on_body_entered(body: Node2D) -> void:
	for effect in _effects:
		effect._interact(self, body)