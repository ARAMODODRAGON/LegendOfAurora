## node used to handle activation of things
class_name ActivationRule
extends Node

## activators are expected to have the following:
# func _trigger_activator()

## enum reference
const TriggerState := Enum.TriggerState

## the list of triggers and their expected state
@export var trigger_rules: Array[TriggerRule] = []

## the list of activators
@export var activators: Array[Node] = []

## state
var _has_triggered: bool = false


func _ready() -> void:
	const signal_name: StringName = &"on_state_change"

	for i in trigger_rules.size():
		var trigger := get_node(trigger_rules[i].trigger_reference) as TriggerBase
	
		var rule_index: int = i # lambda capture
		trigger.on_state_change.connect(
			func(state: TriggerState) -> void:
				_trigger_state_changed(rule_index, state)
		)

		print("Connected ")


func _trigger_state_changed(rule_index: int, state: TriggerState) -> void:
	## set the is_triggered based on if the state is in the expected state
	trigger_rules[rule_index].is_triggered = trigger_rules[rule_index].expected_state == state

	## validate the trigger rules and activate if all are active
	_validate_rules()

func _validate_rules() -> void:
	const callable_name: StringName = &"_trigger_activator"

	var triggered: int = 0

	for rule in trigger_rules:
		if rule.is_triggered:
			triggered += 1
	
	if triggered != trigger_rules.size():
		return
	
	for activator in activators:
		if activator.has_method(callable_name):
			activator.call(callable_name)
		else:
			printerr("Could not activate \"" + activator.name + "\" because it did not have method: \"" + callable_name +"\"")


func _trigger_activators() -> void:
	print("All triggers were triggered!")
	pass


## custom editor stuff
#
# https://forum.godotengine.org/t/how-do-i-create-an-export-variable-that-allows-adding-a-list-of-complex-elements-like-optionbuttons-do/116024
# func __get_property_list() -> Array[Dictionary]:
# 	var props: Array[Dictionary] = []
#
# 	# Special Group Array
# 	props.append({
# 		"name": "trigger_rule",
# 		# class_name format <Group Name>,<prefix>
# 		"class_name": "Trigger Rules,trigger_rule/trigger_rule_",
# 		"type": TYPE_INT,
# 		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT
# 	})
#
# 	for i in trigger_rules.size():
# 		# Each array entry needs to have the prefix items/item_
# 		# followed by the index and the name of the property
# 		props.append({
# 			"name": "items/item_%s/name" % i,
# 			"type": TYPE_NODE_PATH,
# 			"hint": PROPERTY_HINT_NONE,
# 		})
# 		props.append({
# 			"name": "items/item_%s/price" % i,
# 			"type": TYPE_INT,
# 			"hint": PROPERTY_HINT_NONE,
# 		})
#
# 	return props
