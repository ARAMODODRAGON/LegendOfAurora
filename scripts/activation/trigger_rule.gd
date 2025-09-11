## resource used to define special requirements
class_name TriggerRule 
extends Resource

## enum reference
const TriggerState := Enum.TriggerState

## the path to the target node
@export var trigger_reference: NodePath

## the expected state for the node
@export var expected_state: TriggerState = TriggerState.ON

## the state that the trigger is in
var is_triggered: bool = false