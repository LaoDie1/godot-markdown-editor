#============================================================
#    Cast Target
#============================================================
# - datetime: 2023-03-04 16:03:21
# - version: 4.x
#============================================================
class_name CastTarget
extends RayCast2D


func cast_to(global_pos: Vector2, from : Vector2 = Vector2.INF) -> Vector2:
	if from != Vector2.INF:
		global_position = from
	target_position = to_local(global_pos)
	force_raycast_update()
	if is_colliding():
		return get_collision_point()
	return Vector2.INF

