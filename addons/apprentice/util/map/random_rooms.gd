#============================================================
#    Random Rooms
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-20 18:02:10
# - version: 4.0
#============================================================
## 生成随机房间
class_name RandomRooms


signal generated


var size : Vector2i = Vector2i(0, 0)
var rooms_data : Dictionary = {}

var _tmp_row_to_down_intersections = {}


#============================================================
#  SetGet
#============================================================
## 获取生成的数据列表
func get_values() -> Array:
	return rooms_data.values()

## 获取行数列表
func get_rows() -> Array:
	return rooms_data.keys()

## 是否有这个坐标位置
func has_coords(coords: Vector2i) -> bool:
	if rooms_data.has(coords.y):
		var data = rooms_data[coords.y]
		return coords >= data["offset"] and coords <= data["offset"] + data["count"]
	return false

## 获取这个行的所有列
func get_columns(row: int) -> Array[int]:
	assert(rooms_data.has(row), "没有这行的数据")
	return Array(range(rooms_data[row]["offset"], rooms_data[row]["offset"] + rooms_data[row]["count"]), TYPE_INT, "", null)

## 获取这一行的坐标列表
func get_coords_by_row(row: int) -> Array[Vector2i]:
	return Array(get_columns(row).map(func(column):
		return Vector2i(column, row)
	), TYPE_VECTOR2I, "", null)

## 向下移动的交叉的路口列 (x轴)
func get_intersections(from_row: int, to_row: int) -> Array:
	var id = DataUtil.as_set_hash([from_row, to_row])
	if not _tmp_row_to_down_intersections.has(id):
		var from_row_data = rooms_data[from_row]
		var to_row_data = rooms_data[to_row]
		var from_row_columns = range(from_row_data["offset"], from_row_data["offset"] + from_row_data["count"])
		var to_row_columns = range(to_row_data["offset"], to_row_data["offset"] + to_row_data["count"])
		# 记录到据中
		_tmp_row_to_down_intersections[id] = to_row_columns.filter(func(coords): 
			return from_row_columns.has(coords)
		)
	
	return _tmp_row_to_down_intersections[id]


## 获取周围可通向外面的房间坐标
##[br]
##[br][code]coords[/code]  所在坐标位置
func get_passway_directions(coords: Vector2i) -> Array[Vector2i]:
	if rooms_data.has(coords.y):
		var row : int = coords.y
		var column : int = coords.x
		
		# 获取上下方的可通行的路径
		var up_list : Array = []
		var down_list : Array = []
		var curr_list : Array = get_columns(row)
		if rooms_data.has(row - 1):
			up_list = get_columns(row - 1)
		if rooms_data.has(row + 1):
			down_list = get_columns(row + 1)
		
		# 返回结果
		var result : Array[Vector2i] = []
		if up_list.has(column):
			result.append(Vector2i.UP)
		if down_list.has(column):
			result.append(Vector2i.DOWN)
		if curr_list.has(column - 1):
			result.append(Vector2i.LEFT)
		if curr_list.has(column + 1):
			result.append(Vector2i.RIGHT)
		return result
	return []



#============================================================
#  自定义
#============================================================
##  生成
##[br]
##[br][code]column_count_min[/code]  最小列数量
##[br][code]column_count_max[/code]  最大列数量
##[br][code]start_pos[/code]  生成房间开始的位置
func generate(
	column_count_min : int = 0, 
	column_count_max : int = 0, 
	start_pos : Vector2i = Vector2i(0, 0)
) -> void:
	assert(size != Vector2i.ZERO, "地图大小必须过 0！")
	assert(column_count_max < size.x, "最大值不能超出大小")
	assert(column_count_min < column_count_max, "最小值不能超过最大值")
	
	rooms_data = {}
	_tmp_row_to_down_intersections = {}
	
	for row in size.y:
		rooms_data[row] = {
			"count": 0,
			"offset": 0,
			"row": row,
		}
	
	# 每行房间数量
	for row in size.y:
		# 当前行房间数量
		rooms_data[row]["count"] = randi_range(column_count_min, column_count_max)
	
	# 位置偏移
	rooms_data[0]["offset"] = randi_range(max(start_pos.x, 0), min(start_pos.x + rooms_data[0]["count"], size.x - rooms_data[0]["count"]))
	for row in range(1, size.y):
		# 当前这一行偏移位置
		var offset_min_x = rooms_data[row - 1]["offset"] - rooms_data[row]["count"] + 1
		var offset_max_x = rooms_data[row - 1]["offset"] + rooms_data[row - 1]["count"] - 1
		var pos_x = randi_range(max(offset_min_x, 0), min(offset_max_x, size.x - rooms_data[row]["count"]))
		rooms_data[row]["offset"] = pos_x
	
	self.generated.emit()


## 输出显示
func display() -> void:
	for row in size.y:
		var data = rooms_data[row]
		var s = " ".repeat(data["offset"]) \
			+ "#".repeat(data["count"]) \
			+ " ".repeat(size.x - data["offset"] - data["count"]) \
			+ ";"
		print(s)
	print("-".repeat(size.x), ";")

