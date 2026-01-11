@abstract class_name Ability
extends Node


## enum reference
const Direction := Enum.Direction


## required overrides


## called to setup the ability once attached to the player
## attach any hitboxes to the sprite root when setting up
@abstract func setup(sprite_root: Node2D) -> void


## called when this ability should activate
@abstract func commanded(facing: Direction, root: Node2D, sprite: AnimatedSprite2D, extent_offset: Vector2) -> void


## called to update this ability only after commanded is called
@abstract func process(delta: float, facing: Direction) -> void


## if this ability gets interrupted then this ability gets called
@abstract func interrupt() -> void


## called to check if this ability is done
## if its done then processing stops
@abstract func is_done() -> bool


## optional overrides


## override player stats
## return null to default stats 
func player_stat_override() -> PlayerStats:
	return null


## should the player be able to move while using this ability?
func should_move() -> bool:
	return false


## should the player be able to rotate while using this ability?
func should_rotate() -> bool:
	return false


## can this ability be interrupted?
func can_interrupt() -> bool:
	return true