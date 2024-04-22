#============================================================
#    Physics 2D Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-27 09:23:51
# - version: 4.0
#============================================================
## 物理工具
class_name PhysicsUtil


## 获取引擎启动后已经过的物理帧时间
static func get_physics_time() -> float:
	return Engine.get_physics_frames() / float(ProjectSettings.get_setting_with_override("physics/common/physics_ticks_per_second"))

## 获取每秒物理周期数
static func get_physics_ticks_per_second() -> int:
	return ProjectSettings.get_setting_with_override("physics/common/physics_ticks_per_second")

## 获取每秒最大物理周期数
static func get_max_physics_steps_per_frame() -> int:
	return ProjectSettings.get_setting_with_override("physics/common/max_physics_steps_per_frame")

## 获取当前世界的物理状态
static func get_physics_direct_space_state_2d() -> PhysicsDirectSpaceState2D:
	var current_scene := Engine.get_main_loop().current_scene as Node2D
	var world := current_scene.get_world_2d() as World2D
	return world.direct_space_state as PhysicsDirectSpaceState2D


## 获取射线位置检测到的节点。数据结果格式详见 [method PhysicsDirectSpaceState2D.intersect_ray]
static func detect_ray(
	from: Vector2, 
	to: Vector2, 
	collide_with_areas: bool = true,
	collide_with_bodies: bool = true,
	collision_mask: int = 0xFFFFFFFF, 
	exclude: Array[RID] = [],
	world_node: Node2D = null
) -> Dictionary:
	var query_params := PhysicsRayQueryParameters2D.create( from, to, collision_mask, exclude )
	query_params.collide_with_areas = collide_with_areas
	query_params.collide_with_bodies = collide_with_bodies
	return (get_physics_direct_space_state_2d() 
		if world_node == null 
		else world_node.get_world_2d()
	).intersect_ray(query_params)


## 检测圆形范围内的物理单位。数据结果格式详见 [method PhysicsDirectSpaceState2D.intersect_shape]
static func detect_circle_range(
	position: Vector2,
	radius : float,
	collide_with_areas: bool = true,
	collide_with_bodies: bool = true,
	collision_mask: int = 0xFFFFFFFF, 
	exclude: Array[RID] = [],
) -> Array[Dictionary]:
	var params = PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = collide_with_areas
	params.collide_with_bodies = collide_with_bodies
	params.collision_mask = collision_mask
	params.transform = Transform2D(0, position)
	params.exclude = exclude
	
	var circle = CircleShape2D.new()
	circle.radius = radius
	params.shape = circle
	return get_physics_direct_space_state_2d().intersect_shape(params)


static func set_disabled(coll_obj: CollisionObject2D, disabled: bool):
	for owner_id in coll_obj.get_shape_owners():
		coll_obj.shape_owner_get_owner(owner_id).set_deferred("disabled", disabled)
