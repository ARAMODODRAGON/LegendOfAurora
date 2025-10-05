extends CharacterBody2D
class_name Player

## enum reference
const Direction := Enum.Direction


signal entered_warp(warp: WarpPoint)
signal death_animation_end()
signal shake_screen(scale: float, duration: float)


var primary_ability: Ability = null
var secondary_ability: Ability = null

@export var default_stats: PlayerStats

@export var KNOCKBACK_SPEED: float
@export var SHOCKWAVE_TIME: float

@onready var body_sprite: PlayerBody = $BodySprite
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var knockback_timer: Timer = $Timers/KnockbackTimer

@onready var health_component: HealthComponent = $HealthComponent
@onready var interactor_component: InteractorComponent = $InteractorComponent

#@onready var shockwave_pivot: Node2D = $BongoShockwave/ShockwavePivot
#@onready var shockwave_shape: CollisionShape2D = $BongoShockwave/ShockwaveShape
#@onready var bongo_hit_sound: AudioStreamPlayer = $BongoShockwave/BongoHitSound
@onready var _crush_overlap_box: Area2D = $CrushOverlapBox


enum MoveState {
	DEFAULT,
	KNOCKBACK,
}


enum ActionState {
	DEFAULT,
	ACTIONING,
	DEAD,
}


var _move_state: MoveState = MoveState.DEFAULT
var _action_state: ActionState = ActionState.DEFAULT
var _overlapping_solid_frame_count: int = 0
var _commanded_ability: Ability = null
var _facing_direction: Direction = Direction.DOWN
var _last_position: Vector2


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
	_last_position = global_position


func _get_input_dir() -> Vector2:
	match _action_state:
		ActionState.DEAD:
			return Vector2.ZERO
		_:
			var input_dir: Vector2 = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").normalized()
			return input_dir


func _process(delta: float) -> void:
	var input_dir: Vector2 = _get_input_dir()
	var is_walking: bool = not _last_position.is_equal_approx(global_position)

	_update_direction(input_dir)

	if _commanded_ability and not _commanded_ability.is_done():
		pass
	else:
		body_sprite.update_animation(delta, is_walking, _facing_direction)

	_last_position = global_position


func _update_direction(input_dir: Vector2) -> void:
	if _commanded_ability and not _commanded_ability.should_rotate():
		return

	var _facingh: Direction = Direction.NONE
	var _facingv: Direction = Direction.NONE
	
	if abs(input_dir.x) > 0.001:
		if input_dir.x > 0.0:
			_facingh = Direction.RIGHT
		else:
			_facingh = Direction.LEFT
	
	if abs(input_dir.y) > 0.001:
		if input_dir.y > 0.0:
			_facingv = Direction.DOWN
		else:
			_facingv = Direction.UP
	
	var last_facing_direction: Direction = _facing_direction

	if _facing_direction != _facingh && _facing_direction != _facingv:
		if _facingh != Direction.NONE:
			_facing_direction = _facingh
		elif _facingv != Direction.NONE:
			_facing_direction = _facingv
	

func _handle_action(delta: float) -> void:
	var primary_action: bool = Input.is_action_just_pressed("PRIMARY")
	var secondary_action: bool = Input.is_action_just_pressed("SECONDARY")

	match _action_state:
		ActionState.DEFAULT:
			var did_interact: bool = false

			if primary_action:
				did_interact = interactor_component.trigger_interaction(
					Enum.vector_from_direction(_facing_direction)
					## TODO: add in the interaction callback
				)

			if not did_interact:
				_handle_abilities(primary_action, secondary_action)
			
			
		ActionState.ACTIONING:

			if not _commanded_ability:
				_action_state = ActionState.DEFAULT
				return
			
			_commanded_ability.process(delta, _facing_direction)

			if _commanded_ability.is_done():
				body_sprite.reset_animation(_facing_direction)
				_action_state = ActionState.DEFAULT
				_commanded_ability = null

		_: pass


func _handle_abilities(primary_action: bool, secondary_action: bool) -> void:

	if primary_action and primary_ability:
		_commanded_ability = primary_ability
	elif secondary_action and secondary_ability:
		_commanded_ability = secondary_ability
	else:
		## exit early because we did not enter actioning state
		return

	var extent_offset: Vector2 = body_sprite.get_marker_position(_facing_direction)
	_commanded_ability.commanded(_facing_direction, self, body_sprite, extent_offset)
	_action_state = ActionState.ACTIONING

func _physics_process(delta: float) -> void:
	_handle_action(delta)
	_handle_physics(delta)
	_handle_crush()


func _handle_physics(delta: float) -> void:
	var input_dir: Vector2 = Util.restrict_vector_four_directional(_get_input_dir())

	match _move_state:
		MoveState.KNOCKBACK:
			# run the set velocity
			move_and_slide()
		MoveState.DEFAULT, _:

			var stats: PlayerStats = null
			var can_move: bool = true

			if _commanded_ability:
				stats = _commanded_ability.player_stat_override()
				can_move = _commanded_ability.should_move()
			
			if stats == null:
				stats = default_stats

			if can_move:		
				## determine the movement speed and apply it to velocity
				var speed: float = stats.walk_speed
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

	if _commanded_ability:
		_commanded_ability.interrupt()
		_commanded_ability = null

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


func _unhandled_input(event: InputEvent) -> void:
	#if not Engine.is_editor_hint():
	#	return
	
	var key_event := event as InputEventKey
	if key_event:
		match key_event.keycode:
			KEY_F1:
				if GameState.white_sword_unlock.is_unlocked() == false:
					print("Unlocked white sword!")
				GameState.white_sword_unlock.unlock()
				primary_ability = WhiteSwordAbility.new()
				primary_ability.setup(body_sprite)
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
