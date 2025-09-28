extends CharacterBody2D

@export var _sprite: Sprite2D = null
@export var _key_sprite: Sprite2D = null


var _is_open: bool = false


func _on_interactable_component_interact() -> void:
	if _is_open:
		return
	
	_is_open = true

	_key_sprite.visible = true
	_sprite.frame = 1

	var tween := create_tween()
	tween.tween_property(_key_sprite, "position:y", -18.0, 0.7).set_ease(Tween.EASE_OUT)
	
	await tween.finished

	_key_sprite.visible = false
	GameState.level_state().add_key()
