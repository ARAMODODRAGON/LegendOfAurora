extends ActivationObject

enum DoorState{
	CLOSED_UNLOCKED,
	LOCKED_WITH_KEY,
	LOCKED_GATED,
	OPEN
}

@export var initial_state: DoorState = DoorState.CLOSED_UNLOCKED