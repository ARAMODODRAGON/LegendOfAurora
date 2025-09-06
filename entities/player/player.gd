extends CharacterBody2D
class_name Player

signal entered_warp(warp: WarpPoint)
signal death_animation_end()

@export var WALK_SPEED: float
@export var KNOCKBACK_SPEED: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var knockback_timer: Timer = $Timers/KnockbackTimer

@onready var health_component: HealthComponent = $HealthComponent
@onready var interactor_component: InteractorComponent = $InteractorComponent
@onready var flute_component: FluteComponent = $FluteComponent

enum MoveState {
	DEFAULT,
	KNOCKBACK,
	ATTACKING,
}

enum ActionState {
	DEFAULT,
	DEAD, 
	FLUTE
}

var _move_state: MoveState = MoveState.DEFAULT
var _action_state: ActionState = ActionState.DEFAULT

func is_dead() -> bool:
	return _action_state == ActionState.DEAD

func _ready() -> void:
	body_sprite.death_animation_end.connect(death_animation_end.emit)
	body_sprite.attack_end.connect(
		func() -> void:
			if _move_state == MoveState.ATTACKING:
				_move_state = MoveState.DEFAULT
	)

func _get_input_dir() -> Vector2:
	match _action_state:
		ActionState.DEAD, ActionState.FLUTE:
			return Vector2.ZERO
		_:
			var input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
			return input_dir

func _process(delta: float) -> void:
	body_sprite.update_animation(delta, _get_input_dir())

func _handle_action() -> void:
	var primary_action: bool = Input.is_action_just_pressed("PRIMARY")
	var secondary_action: bool = Input.is_action_just_pressed("SECONDARY")

	match _action_state:
		ActionState.DEFAULT:

			if primary_action and not body_sprite.is_attacking(): 
				var did_interact: bool = interactor_component.trigger_interaction(
					body_sprite.get_facing_vector(), 
					_on_interactable_triggered
				)

				if !did_interact:
					body_sprite.attack()
					_move_state = MoveState.ATTACKING
					velocity = Vector2.ZERO
				
			elif secondary_action:
				#_action_state = ActionState.FLUTE
				pass
			
		ActionState.FLUTE:
			var up_input: bool = Input.is_action_just_pressed("UP")
			var down_input: bool = Input.is_action_just_pressed("DOWN")
			var left_input: bool = Input.is_action_just_pressed("LEFT")
			var right_input: bool = Input.is_action_just_pressed("RIGHT")
			
			if primary_action or secondary_action:
				_action_state = ActionState.DEFAULT
				return
			
			if up_input:
				flute_component.try_play_note(Enum.Direction.UP)
			elif down_input:
				flute_component.try_play_note(Enum.Direction.DOWN)
			elif left_input:
				flute_component.try_play_note(Enum.Direction.LEFT)
			elif right_input:
				flute_component.try_play_note(Enum.Direction.RIGHT)

		_: pass

func _on_interactable_triggered(interactable: InteractableComponent) -> void:
	pass

func _physics_process(delta: float) -> void:
	_handle_action()
	_handle_physics(delta)

	
func _handle_physics(delta: float) -> void:
	var input_dir: Vector2 = _get_input_dir()
	match _move_state:
		MoveState.KNOCKBACK, MoveState.ATTACKING:
			# run the set velocity
			move_and_slide() 
		MoveState.DEFAULT, _:
			## determine the movement speed and apply it to velocity
			var speed: float = WALK_SPEED
			velocity = input_dir * speed
			
			move_and_slide()

func _apply_regular_knockback(direction: Vector2) -> void:
	if _move_state == MoveState.KNOCKBACK:
		return
	
	_move_state = MoveState.KNOCKBACK

	knockback_timer.start()
	velocity = direction * KNOCKBACK_SPEED

func _apply_killing_knockback(direction: Vector2) -> void:
	_apply_regular_knockback(direction)

	# cancel timer
	knockback_timer.stop()

	# apply tween to slow down the player to a stop
	var t: Tween = create_tween()
	t.tween_property(self, "velocity", Vector2.ZERO, knockback_timer.wait_time * 3.0)

func _on_knockback_timer_timeout() -> void:
	if _move_state == MoveState.KNOCKBACK:
		_move_state = MoveState.DEFAULT

func _on_warp_entered(area: Area2D) -> void:
	if spawn_timer.is_stopped() == false: return

	var warp: WarpPoint = area as WarpPoint
	if warp == null: return
	entered_warp.emit(warp)

func _on_take_damage(damage: int, direction: Vector2) -> void:
	if damage == 0:
		return

	if health_component.health > 0:
		# damage animation
		body_sprite.take_damage(knockback_timer.wait_time)
		
		# apply knockback
		_apply_regular_knockback(direction)
	else:
		# apply knockback
		_apply_killing_knockback(direction)


func _on_die() -> void:
	_action_state = ActionState.DEAD
	body_sprite.die()
