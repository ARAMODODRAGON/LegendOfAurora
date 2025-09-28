@abstract class_name HitEffect
extends Node


## override to provide a reaction to touching another hitbox
func _trigger(parent: Hitbox, target: Hitbox) -> void: pass


## override to provide a reaction to touching a body
func _interact(parent: Hitbox, body: Node2D) -> void: pass