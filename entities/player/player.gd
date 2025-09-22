extends CharacterBody2D
class_name Player

signal entered_warp(warp: WarpPoint)
signal death_animation_end()
signal shake_screen(scale: float, duration: float)

@export var WALK_SPEED: float
@export var KNOCKBACK_SPEED: float
@export var SHOCKWAVE_TIME: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var knockback_timer: Timer = $Timers/KnockbackTimer

@onready var health_component: HealthComponent = $HealthComponent
@onready var interactor_component: InteractorComponent = $InteractorComponent

@onready var shockwave_pivot: Node2D = $BongoShockwave/ShockwavePivot
@onready var shockwave_shape: CollisionShape2D = $BongoShockwave/ShockwaveShape
@onready var bongo_hit_sound: AudioStreamPlayer = $BongoShockwave/BongoHitSound
@onready var _crush_overlap_box: Area2D = $CrushOverlapBox

enum MoveState {
	DEFAULT,
	KNOCKBACK,
	ATTACKING,
}

enum ActionState {
	DEFAULT,
	SHOCKWAVE,
	DEAD,
}

var _move_state: MoveState = MoveState.DEFAULT
var _action_state: ActionState = ActionState.DEFAULT
var _overlapping_solid_frame_count: int = 0

func is_dead() -> bool:
	return _action_state == ActionState.DEAD


func trigger_spawn_timer() -> void:
	spawn_timer.start()


func _enter_tree() -> void:
	Game._player_reference = self


func _exit_tree() -> void:
	if Game._player_reference == self:
		Game._player_reference = null


func _ready() -> void:
	body_sprite.death_animation_end.connect(death_animation_end.emit)
	body_sprite.attack_end.connect(
		func() -> void:
			if _move_state == MoveState.ATTACKING:
				_move_state = MoveState.DEFAULT
	)


func _get_input_dir() -> Vector2:
	match _action_state:
		ActionState.DEAD:
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
			if primary_action and not body_sprite.is_attacking() and GameState.white_sword_unlock.is_unlocked():
				var did_interact: bool = interactor_component.trigger_interaction(
					body_sprite.get_facing_vector(),
					_on_interactable_triggered
				)

				if !did_interact:
					body_sprite.attack()
					_move_state = MoveState.ATTACKING
					velocity = Vector2.ZERO
				
			elif secondary_action and not body_sprite.is_attacking() and GameState.bongo_unlock.is_unlocked():
				_trigger_shockwave()
			
		_: pass


func _trigger_shockwave() -> void:
	if _action_state == ActionState.SHOCKWAVE:
		return

	bongo_hit_sound.play()
	_action_state = ActionState.SHOCKWAVE
	shockwave_shape.set_deferred("disabled", false)
	shake_screen.emit(0.6, SHOCKWAVE_TIME * 0.2)

	var tween0: Tween = create_tween()

	shockwave_pivot.modulate = Color.TRANSPARENT
	tween0.tween_property(shockwave_pivot, "modulate", Color.WHITE, SHOCKWAVE_TIME * 0.5)
	tween0.tween_property(shockwave_pivot, "modulate", Color.TRANSPARENT, SHOCKWAVE_TIME * 0.5)

	tween0.tween_callback(
		func() -> void:
			_action_state = ActionState.DEFAULT
			shockwave_shape.set_deferred("disabled", true)
	)

	var tween1: Tween = create_tween()
	shockwave_pivot.scale = Vector2.ZERO
	tween1.tween_property(shockwave_pivot, "scale", Vector2.ONE, SHOCKWAVE_TIME)


func _on_interactable_triggered(interactable: InteractableComponent) -> void:
	pass


func _physics_process(delta: float) -> void:
	_handle_action()
	_handle_physics(delta)
	_handle_crush()


func _handle_physics(delta: float) -> void:
	var input_dir: Vector2 = Util.restrict_vector_four_directional(_get_input_dir())

	match _move_state:
		MoveState.KNOCKBACK, MoveState.ATTACKING:
			# run the set velocity
			move_and_slide()
		MoveState.DEFAULT, _:
			## determine the movement speed and apply it to velocity
			var speed: float = WALK_SPEED
			velocity = input_dir * speed
			
			move_and_slide()


func _handle_crush() -> void:
	if _action_state == ActionState.DEAD:
		return

	if not _crush_overlap_box.has_overlapping_bodies():
		_overlapping_solid_frame_count = 0
		return
	
	_overlapping_solid_frame_count += 1

	if _overlapping_solid_frame_count > 3:
		_on_die()


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


func _on_bongo_shockwave_area_entered(area: Area2D) -> void:
	var bongo_listener := area as BongoListenerComponent
	if bongo_listener:
		bongo_listener.bongo_hit.emit(area.global_position - global_position)

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		return
	
	var key_event := event as InputEventKey
	if key_event:
		match key_event.keycode:
			KEY_F1:
				if GameState.white_sword_unlock.is_unlocked() == false:
					print("Unlocked white sword!")
				GameState.white_sword_unlock.unlock()
			KEY_F2:
				if GameState.bongo_unlock.is_unlocked() == false:
					print("Unlocked bongo!")
				GameState.bongo_unlock.unlock()
			KEY_1:
				var level := GameState.level_state()
				level.add_key()
			KEY_2:
				var level := GameState.level_state()
				level.use_key()
