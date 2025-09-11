extends Area2D
class_name WarpPoint

## the target map to load from the build index
## default -1 means that the target warp is in the same scene
@export var target_map_index: int = -1

## the warp to go to, can be in the same scene
## if left blank then will assume player spawn
@export var target_warp_name: String