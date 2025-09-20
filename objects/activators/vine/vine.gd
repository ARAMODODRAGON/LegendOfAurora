extends ActivationObject
class_name GatedVine


@export var _linked_vine: GatedVine = null


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collisionshape: CollisionShape2D = $StaticBody2D/CollisionShape2D


var _first_frame: int


func _ready() -> void:
	_first_frame = _sprite.frame

## opens
func _on_triggered_on() -> void: 
	if _linked_vine:
		_linked_vine._trigger_open()
	_trigger_open()

func _trigger_open() -> void:
	const fps: float = 1.0/5.0

	_sprite.frame = _first_frame + 1

	await get_tree().create_timer(fps).timeout

	_collisionshape.disabled = true
	_sprite.frame = _first_frame + 2

	