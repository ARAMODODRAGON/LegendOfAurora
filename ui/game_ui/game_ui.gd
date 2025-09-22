class_name GameUI
extends CanvasLayer

# using
const LevelState = GameState.LevelState


@onready var _key_text: RichTextLabel = $Control/HBoxContainer/MarginContainer/RichTextLabel


func _ready() -> void:
	GameState.update_ui.connect(_game_state_update_ui)


func _game_state_update_ui(state: LevelState) -> void:
	_key_text.text = "x" + str(state.get_key_count())