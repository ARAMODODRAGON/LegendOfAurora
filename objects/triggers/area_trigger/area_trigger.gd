class_name AreaTrigger
extends TriggerBase

## exports
@export var detect_body: bool = true
@export var detect_area: bool = false
@export_flags_2d_physics var collision_mask: int


## private
var _area: Area2D = null


## methods

func _ready() -> void:
	super._ready()
	
	# create new area
	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = collision_mask
	add_child(_area)

	# reattach collision shapes to a new area
	var children := get_children()

	for child in children:

		var shape := child as CollisionShape2D
		if shape:
			remove_child(shape)
			_area.add_child(shape)
	
	if detect_body:
		_area.body_entered.connect(_on_body_entered)

	if detect_area:
		_area.area_entered.connect(_on_area_entered)


func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return
	update_state.call_deferred(TriggerState.ON)

func _on_area_entered(area: Area2D) -> void:
	if not enabled:
		return
	update_state.call_deferred(TriggerState.ON)