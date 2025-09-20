class_name GatedDoor
extends ActivationObject


@export var _linked_door: GatedDoor = null


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collisionshape: CollisionShape2D = $StaticBody2D/CollisionShape2D


var _first_frame: int


func _ready() -> void:
	_first_frame = _sprite.frame

## opens
func _on_triggered_on() -> void: 
	if _linked_door:
		_linked_door._trigger_open()
	_trigger_open()

func _trigger_open() -> void:
	_sprite.frame = _first_frame + 1
	_collisionshape.disabled = true