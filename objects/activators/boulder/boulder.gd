extends ActivationObject

## exports 

@export var can_trigger: bool = true
@export var start_despawned: bool = false


## references

@onready var _collisionshape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D


## virtual functions

func _on_triggered_on() -> void: 
	if not can_trigger:
		return

	if start_despawned:
		_collisionshape.disabled = false
		_sprite.visible = true
	else:
		_collisionshape.disabled = true
		_sprite.visible = false



func _on_triggered_off() -> void: 
	if not can_trigger:
		return

	if start_despawned:
		_collisionshape.disabled = true
		_sprite.visible = false
	else:
		_collisionshape.disabled = false
		_sprite.visible = true


## methods

func _ready() -> void:
	if start_despawned:
		_collisionshape.disabled = true
		_sprite.visible = false