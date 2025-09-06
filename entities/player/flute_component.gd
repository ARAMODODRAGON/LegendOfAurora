class_name FluteComponent
extends Node2D

@export var stream_note_up: AudioStream
@export var stream_note_down: AudioStream
@export var stream_note_left: AudioStream
@export var stream_note_right: AudioStream
@export var note_texture: Texture

@onready var note_delay: Timer = $NoteDelay

var _stream_max_length: float = 10.0
#var _note_packed_scene: PackedScene

func try_play_note(direction: Enum.Direction) -> void:
	if not note_delay.is_stopped():
		return

	var note: Sprite2D = Sprite2D.new()
	note.texture = note_texture
	note.hframes = 2
	note.vframes = 2
	note.frame = _frame_from_dir(direction)

	var sound: AudioStreamPlayer = AudioStreamPlayer.new()
	sound.stream = stream_note_up # TODO: replace with sound based on direction
	sound.autoplay = true
	
	note.add_child(sound)

	add_child(note)


	var tween: Tween = note.create_tween()
	
	tween.tween_interval(0.7)
	tween.tween_property(note, "self_modulate", Color.TRANSPARENT, _stream_max_length * 0.3)

	tween.parallel().tween_property(note, "position", _vector_from_dir(direction), _stream_max_length)


	note_delay.start()

func _stream_from_dir(direction: Enum.Direction) -> AudioStream:
	match direction:
		Enum.Direction.UP:
			return stream_note_up
		Enum.Direction.DOWN:
			return stream_note_down
		Enum.Direction.LEFT:
			return stream_note_left
		_, Enum.Direction.RIGHT:
			return stream_note_right

func _vector_from_dir(direction: Enum.Direction) -> Vector2:
	match direction:
		Enum.Direction.UP:
			return Vector2.UP
		Enum.Direction.DOWN:
			return Vector2.DOWN
		Enum.Direction.LEFT:
			return Vector2.LEFT
		_, Enum.Direction.RIGHT:
			return Vector2.RIGHT

func _frame_from_dir(direction: Enum.Direction) -> int:
	match direction:
		Enum.Direction.UP:
			return 0
		Enum.Direction.DOWN:
			return 1
		Enum.Direction.LEFT:
			return 2
		_, Enum.Direction.RIGHT:
			return 3

func _ready() -> void:
	_stream_max_length = max(
		stream_note_up.get_length(), 
		stream_note_down.get_length(),
		stream_note_left.get_length(),
		stream_note_right.get_length()
	)	
