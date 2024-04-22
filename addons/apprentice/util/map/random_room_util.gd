#============================================================
#    Generate Room Util
#============================================================
# - datetime: 2022-10-03 22:14:25
#============================================================
##  生成房间坐标工具（废弃）
class_name RandomRoomUtil


#============================================================
#  SetGet
#============================================================
## 地图大小
var size : Vector2i = Vector2i()
## 最终房间位置
var end : Vector2i = Vector2i()
## 移动路径记录
var visited : Dictionary = {}
## 向下移动到的位置的开始行，行对应坐标位置
var line_downed_data : Dictionary = {}


## 获取坐标列表
func get_coord_list() -> Array:
	return visited.keys() 

## 获取坐标数据
func get_coord_data() -> Dictionary:
	return visited

## 获取向下移动到的位置的坐标
func get_line_downed_data() -> Dictionary:
	return line_downed_data

func get_line_down_by_row(row: int) -> Vector2i:
	return line_downed_data.get(row, MathUtil.VECTOR2I_MAX)

## 获得起始坐标
func get_start_coord() -> Vector2i:
	if visited.size() > 0:
		return visited.keys()[0] as Vector2i
	else:
		return Vector2i.ZERO

## 获取末尾位置
func get_end_coord() -> Vector2i:
	if visited.is_empty():
		return Vector2i.ZERO
	return visited.keys().back() as Vector2i

func has_coords(coords: Vector2i) -> bool:
	return visited.has(coords)


#============================================================
#  自定义方法
#============================================================
## 生成
func generate(
	line_count_min : int = 0, 
	line_count_max : int = 0, 
	start_pos : Vector2i = Vector2i(0, 0)
) -> Array:
	assert(size != Vector2i.ZERO, "地图大小必须过 0！")
	assert(line_count_max < size.x, "最大值不能超出大小")
	assert(line_count_min < line_count_max, "最小值不能超过最大值")
	
	var data : Dictionary = {}
	for row in size.y:
		data[row] = {
			"count": 0,
			"pos": Vector2i(0, 0),
		}
	
	for row in size.y:
		# 当前行房间数量
		data[row]['count'] = randi_range(line_count_min, line_count_max + 1)
	
	data[0]['pos'] = start_pos
	for row in range(1, size.y):
		# 当前这一行偏移位置
		var offset_min_x = data[row]["pos"].x
		var offset_max_x = offset_min_x + data[row]["count"].x
		var pos_x = randi_range(offset_min_x, offset_max_x)
		data[row]['pos'] = Vector2i(pos_x, row)
	
	self.line_downed_data = {}
	self.visited = Generator.run(size, line_count_min, line_count_max, line_downed_data)
	return visited.keys()



#============================================================
#  生成器
#============================================================
class Generator:
	
	##  执行生成。size 为生成大小范围，line_min 是每行生成最小数量，line_max 为生成的最大数量
	## line_downed 为上一层下降到的行的坐标数据
	static func run(size:Vector2i, line_min:int, line_max:int, line_downed: Dictionary) -> Dictionary:
		assert(line_max < size.x, "最大值不能超出大小")
		assert(line_min < line_max, "最小值不能超过最大值")
		
		var visited : Dictionary = {}
		var current_p : Vector2i = Vector2i(randi() % size.x , 0)
		var line_count : int = 0
		
		visited[current_p] = null
		
		# 上一行列表
		var previous_line_list : Array = []
		
		var line_direction : int = [-1, 1][randi() % 2]
		var line : int = 0
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
			line_direction = [-1, 1][randi() % 2]
			current_p.y = line
			for i in line_count:
				current_p.x += 1 * line_direction
				if current_p.x >= 0 and current_p.x < size.x:
					visited[current_p] = null
					previous_line_list.append(current_p)
			# 存在有节点（如果上面都是超出的，则还是执行这个 line）
			if previous_line_list.size() > 0:
				# 向下移动到的房间
				var down_p : Vector2i = Vector2i(clamp(previous_start_pos.x, line_min, line_max), line)
				line_downed[line] = down_p
				visited[down_p] = null
				line += 1
				if line == size.y:
					return visited
		
		return visited
	
	
	##  生成获取下一个位置方向
	static func get_next_pos(current_p: Vector2i, size: Vector2i):
		var direction : Vector2i
		while true:
			direction = Vector2i(MathUtil.rand_probability({
				-1: 1,
				1: 1,
				0: 0.5
			}), 0) 
			if direction.x == 0:
				direction.y = 1
			var next_p = current_p + direction
			if next_p.x >= 0 or next_p.x < size.x:
				return next_p
	
