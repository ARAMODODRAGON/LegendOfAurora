class_name ShockwaveAbility
extends Ability


var hitbox: Hitbox = null


func setup(sprite_root: Node2D) -> void: 
	hitbox = sprite_root.get_node("ShockwaveHitbox")
	pass


func commanded(facing: Direction, root: Node2D, sprite: AnimatedSprite2D, extent_offset: Vector2) -> void: 
	pass


func process(delta: float, facing: Direction) -> void: 
	pass


func interrupt() -> void: 
	pass


func is_done() -> bool: 
	return false
