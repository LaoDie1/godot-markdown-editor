#============================================================
#    Generate Map Util
#============================================================
# - datetime: 2022-10-03 22:14:25
#============================================================
##  生成地图坐标工具（废弃）
class_name RandomMapUtil


#============================================================
#  生成器
#============================================================
class Generator:
	
	##  执行生成。size 为生成大小范围，line_min 是每行生成最小数量，line_max 为生成的最大数量
	## line_downed 为上一层下降到的行的坐标数据
	static func run(size:Vector2i, line_min:int, line_max:int, line_downed: Dictionary) -> Dictionary:
		var visited := {}
		var current_p := Vector2i(randi() % size.x , 0)
		var line_count := 0
		
		assert(line_max <= size.x, "最大值不能超出大小")
		assert(line_min <= line_max, "最小值不能超过最大值")
		
		visited[current_p] = null
		
		# 上一行列表
		var previous_line_list = []
		
		var line_direction = [-1, 1].pick_random()
		var line = 0
		while line < size.y:
			# 上一个位置的随机一个位置开始
			var previous_start_pos = current_p
			if previous_line_list.size() > 0:
				previous_start_pos = previous_line_list[randi() % previous_line_list.size()]
				previous_start_pos.x = clamp(previous_start_pos.x, line_min, line_max)
				current_p = previous_start_pos
			previous_line_list.clear()
			# 开始生成
			line_count = randi_range(line_min, line_max)
			line_direction = [-1, 1].pick_random()
			current_p.y = line
			for i in line_count:
				current_p.x += 1 * line_direction
				if current_p.x >= 0 and current_p.x < size.x:
					visited[current_p] = null
					previous_line_list.append(current_p)
			# 存在有节点（如果上面都是超出的，则还是执行这个 line）
			if previous_line_list.size() > 0:
				# 向下移动到的房间
				var down_p = Vector2i(clamp(previous_start_pos.x, line_min, line_max), line)
				line_downed[line] = down_p
				visited[down_p] = null
				line += 1
				if line == size.y:
					return visited
		
		return visited
	
	
	##  获取下一个位置方向
	static func get_next_pos(current_p: Vector2i, size: Vector2i):
		var direction : Vector2i
		while true:
			direction = Vector2i(_rand_list(
				[-1, 1, 0], # 生成方向“左右下”
				[0.5, 0.5, 0.1] # 生成方向的概率
			), 0) 
			if direction.x == 0:
				direction.y = 1
			var next_p = current_p + direction
			if next_p.x >= 0 or next_p.x < size.x:
				return next_p
	
	##  返回对应概率的值
	## @value_list  值列表
	## @probability_list  概率列表
	static func _rand_list(
		value_list : Array,
		probability_list: Array = []
	):
		if probability_list == []:
			probability_list.resize(value_list.size())
		
		# 累加概率值，计算概率总和。每次累加存到列表中作为概率区间
		var sum = 0.0
		var p_list = []	# 概率列表
		for i in probability_list:
			sum += i
			p_list.push_back(sum)
		
		# 产生一个 [0, 概率总和) 之间的随机值概率区间越大的值，则随机到的概率越大
		# 则就实现了每个值的随机值
		var r = randf() * sum
		var idx = 0
		for current_p in p_list:
			# 当前概率超过或等于随机的概率，则返回
			if current_p >= r:
				return value_list[idx]
			idx += 1
		
		return null


#============================================================
#  SetGet
#============================================================
## 地图大小
var size := Vector2i()
## 最终房间位置
var end := Vector2i()
## 移动路径记录
var visited := {}
## 向下移动到的位置的开始行，行对应坐标位置
var line_downed_data := {}


## 获取坐标列表
func get_coord_list() -> Array:
	return visited.keys() 

## 获取生成的坐标数据
func get_points_data() -> Dictionary:
	return visited

## 获取移动路径坐标点
func get_move_path_points() -> Dictionary:
	return line_downed_data

## 获得起始坐标
func get_start_coord() -> Vector2i:
	if visited.size() > 0:
		return visited.keys()[0] as Vector2i
	else:
		return Vector2i.ZERO

## 设置生成大小
func set_size(v: Vector2i) -> RandomMapUtil:
	size = v
	return self


#============================================================
#  自定义方法
#============================================================
## 生成
func generate(line_count_min := 0, line_count_max := 0):
	self.line_downed_data.clear()
	self.visited = Generator.run(size, line_count_min, line_count_max, line_downed_data)
	return visited.keys()


