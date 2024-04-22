#============================================================
#    Projectile
#============================================================
# - datetime: 2023-03-05 12:31:33
# - version: 4.x
#============================================================
## 投射物
class_name Projectile


class ProjectileCreator:
	
	## 回调方法列表，这些方法都要有3个参数：
	##[br] - projectile 接收传入的投射物对象
	##[br] - idx 接收这个对象的索引
	##[br] - total 创建的投射物的总数量
	var _callables : Array[Callable] = []
	
	func _add(callable: Callable) -> ProjectileCreator:
		_callables.append(callable)
		return self
	
	func set_position(position: Vector2) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			projectile["global_position"] = position
		)
	
	func set_direction(direction: Vector2) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			projectile["global_rotation"] = direction.angle() 
		)
	
	func set_rotation(rotation: float) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			projectile["global_rotation"] = rotation
		)
	
	func set_offset_position(position: Vector2) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			if not projectile.is_inside_tree(): await projectile.ready
			projectile['global_position'] += position 
		)
	
	func set_array_offset_position(position: Vector2) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			if not projectile.is_inside_tree(): await projectile.ready
			projectile['global_position'] += position * idx
		)
	
	func set_offset_rotation(angle: float) -> ProjectileCreator:
		return _add(func(projectile: Node2D, idx, total): 
			if not projectile.is_inside_tree(): await projectile.ready
			projectile.rotate(angle)
		)
	
	func set_array_offset_rotation(angle: float) -> ProjectileCreator:
		return _add(func(projectile:Node2D, idx, total): 
			if not projectile.is_inside_tree(): await projectile.ready
			projectile.rotate(angle * idx) 
		)
	
	func set_life_time(life_time: float) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			NodeUtil.create_once_timer(life_time, projectile.queue_free, projectile) 
		)
	
	func set_track_to(tarck: CanvasItem, rotation_speed: float) -> ProjectileCreator:
		return _add(func(projectile, idx, total):
			var turn_controller = TurnController.new()
			turn_controller.execute_mode = TurnController.ExecuteMode.PHYSICS
			turn_controller.rotate_by_node = projectile
			turn_controller.rotation_speed = rotation_speed
			projectile.add_child(turn_controller)
		)
	
	func set_interval_angle(angle: float) -> ProjectileCreator:
		return _add(func(projectile, idx, total):
			if not projectile.is_inside_tree(): await projectile.ready
			projectile['global_position'] += idx * angle
		)
	
	func set_rotation_to(node: Node2D) -> ProjectileCreator:
		return _add(func(projectile: Node2D, idx, total):
			var angle = node.global_position.angle_to_point(projectile.global_position)
			projectile.global_rotation = angle
		)
	
	## 向前移动
	func forward(move_speed: float):
		var delta = Engine.get_main_loop().current_scene.get_physics_process_delta_time()
		return _add(func(projectile: Node2D, idx, total):
			# 向前移动
			var move_forward = MoveForward.new()
			move_forward.moved_direction.connect(func(direction):
				projectile.position += direction * move_speed * delta
			)
			projectile.add_child(move_forward)
		)
	
	## 这个回调方法需要有有3个参数：
	##[br] - projectile 接收传入的投射物对象
	##[br] - idx 接收这个对象的索引
	##[br] - total 创建的投射物的总数量
	func add_custom_callback(callback: Callable) -> ProjectileCreator:
		return _add(callback)
	
	
	## 添加到这个节点上
	##[br][code]to[/code]  添加到这个节点上
	##[br][code]time_callback[/code]  延迟的时间回调。这个参数需要有一个 [int] 类型的参数接收这是第几个投射物，
	##并返回延迟的时间
	func add_to(to: Node, time_callback: Callable = func(idx): return 0) -> ProjectileCreator:
		return _add(func(projectile, idx, total): 
			var time = time_callback.call(idx)
			if time is float or time is int and time > 0:
				await Engine.get_main_loop().create_timer(time).timeout 
			to.add_child(projectile)
		)
	
	## 执行功能
	##[br][code]node_count[/code]  添加的节点的数量
	##[br][code]add_to_node[/code]  添加到这个节点上
	func execute(node_count: int = 1, add_to_node: Node = null) -> Array[CharacterBody2D]:
		assert(node_count > 0, "数量不能低于 0")
		
		# 创建节点
		var node_list : Array[CharacterBody2D] = []
		for idx in node_count:
			var node = CharacterBody2D.new()
			node_list.append(node)
			if add_to_node != null:
				add_to_node.add_child(node)
		
		# 执行功能
		for idx in node_count:
			var node = node_list[idx]
			for callable in _callables:
				callable.call(node, idx, node_count)
		return node_list
	


static func create() -> ProjectileCreator:
	return ProjectileCreator.new()

