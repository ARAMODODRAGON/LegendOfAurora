extends CharacterBody2D
class_name Player

signal entered_warp(warp: WarpPoint)
signal death_animation_end()

@export var WALK_SPEED: float
@export var KNOCKBACK_SPEED: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var knockback_timer: Timer = $Timers/KnockbackTimer

@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var interactor_component: InteractorComponent = $Components/InteractorComponent

enum MoveState {
	DEFAULT,
	KNOCKBACK,
}

var _move_state: MoveState = MoveState.DEFAULT
var _is_dead: bool = false

func is_dead() -> bool:
	return _is_dead

func _ready() -> void:
	body_sprite.death_animation_end.connect(death_animation_end.emit)

func _get_input_dir() -> Vector2:
	if _is_dead:
		return Vector2.ZERO
	else:
		var input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
		return input_dir

func _process(delta: float) -> void:
	body_sprite.update_animation(delta, _get_input_dir())

func _handle_interaction() -> void:
	var primary_action: bool = Input.is_action_just_pressed("PRIMARY")

	if primary_action: 
		interactor_component.trigger_interaction(body_sprite.get_facing_vector(), _on_interactable_triggered)

func _on_interactable_triggered(interactable: InteractableComponent) -> void:
	print(interactable.my_string)

func _physics_process(delta: float) -> void:
	_handle_interaction()
	_handle_physics(delta)

	
func _handle_physics(delta: float) -> void:
	var input_dir: Vector2 = _get_input_dir()
	match _move_state:
		MoveState.KNOCKBACK:
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
	_is_dead = true
	body_sprite.die()
