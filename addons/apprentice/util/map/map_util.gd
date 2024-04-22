#============================================================
#    Map Util
#============================================================
# - datetime: 2023-02-15 21:32:15
#============================================================
class_name MapUtil


## 生成 2D 地形
static func generate_2d_map(map_rect: Rect2i):
	var probability = 0.47
	
	var total = map_rect.size.x * map_rect.size.y
	var min_count = total * 0.35
	var max_count = total * 0.8
	
	var moved = {}
	var exited = []
	var non = []
	var next : Vector2i
	
	var start_pos = (map_rect.position + map_rect.size) / 2
	var dirs = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
	var last_list = []
	
	var current_list = [start_pos]
	var r_pos = Vector2i(MathUtil.rand_vector2().random_in_rect(map_rect))
	if r_pos != start_pos:
		current_list.append(r_pos)
	
	while true:
		
		last_list = current_list
		current_list = []
		
		for pos in last_list:
			for dir in dirs:
				next = pos + dir
				# 没有走过且在范围内，则概率判断
				if map_rect.has_point(next):
					if not moved.has(next) and moved.get(next) != 1:
						if randf() <= probability + MathUtil.rand_probability({
								-0.17: 1, 
								0.17: 1, 
								0.1: 0.2, 
								0.15: 0.5, 
								0.04: 0.2, 
								0.06: 0.4, 
								-0.06: 0.6, 
								-0.12: 0.7
						}):
							moved[next] = 1
							current_list.append(next)
							exited.append(next)
						else:
							non.push_back(next)
		
		if exited.size() > min_count:
			break
		
		if current_list.size() == 0:
			if moved.size() > total:
				break
			else:
				var idx = randi() % non.size()
				var pos = non[idx]
				non.remove_at(idx)
				current_list.append(pos)
	
	return moved



static func generate_steps(height: int, total_width: int, width_getter: Callable) -> Array[Dictionary]:
	var list = []
	# 生成台阶宽度
	for i in height:
		list.push_back(width_getter.call())
	
	var data : Array[Dictionary] = []
	var last_offset = []
	for width in list:
		var offset = randi() % (total_width - width)
		# 几个无贴墙的之后必定生成贴近墙的台阶
		if offset > 0:
			last_offset.append(offset)
			if last_offset.size() >= 5:
				offset = [0, total_width - width].pick_random()
		
		if offset == 0 or offset == total_width - width:
			last_offset.clear()
		
		data.push_back({
			"width": width,
			"offset": offset,
		})
	
	return data


