class_name TriggerBase
extends Node2D

## enum

const TriggerState := Enum.TriggerState
signal on_state_change(state: TriggerState)


## default state

@export var default_state: TriggerState
@export var reset_on_room_load: bool = true
@export var reverse_trigger_output: bool = false


## the rules attached to this node

var trigger_rules: Array[TriggerRule]


## private

var _state: TriggerState = TriggerState.OFF


## virtual methods

func _on_triggered_on() -> void: pass
func _on_triggered_off() -> void: pass


func _reset() -> void:
	update_state(default_state)
	#print("reset to default: " + ("ON" if default_state == TriggerState.ON else "OFF"))


func _room_object_load(object_layer: Node) -> void:
	if reset_on_room_load:
		_reset()
	

func _room_object_unload(object_layer: Node) -> void:
	pass


## methods

func get_state() -> TriggerState:
	return _state;

func update_state(state: TriggerState) -> void:
	if _state != state:
		_state = state

		var output_state: TriggerState = _state
		if reverse_trigger_output:
			output_state = Enum.reverse_trigger_state(output_state)

		for rule in trigger_rules:
			rule._update_state.call_deferred(output_state)
		
		if _state:
			_on_triggered_on()
		else:
			_on_triggered_off()

		on_state_change.emit(_state)
	
func _ready() -> void:
	for child in get_children():
		if child is TriggerRule:
			trigger_rules.push_back(child as TriggerRule)
	_reset()


