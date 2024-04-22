#============================================================
#    Map Generate Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-13 17:15:54
# - version: 4.0
#============================================================
## 生成地图工具（待修改，改为自定义的矩形生成的代码，以规则方式生成）
class_name MapGenerateUtil



## 这个地图上的划分的网格中所有单元格区块的地图数据
class RoomBlockMapData:
	
	var tilemap : TileMap
	
	var room_block_size : Vector2i
	var separation : Vector2i
	
	## 存在房间的行列块坐标
	var exists_sub_room_coords : Array[Vector2i] = []
	## 这个方向是有出口的房间的行列块坐标
	var dir_to_sub_room_coords : Dictionary = {}
	## 这个方向集出口都有的房间的哈希值的行列块坐标
	var dir_hash_to_room_coords : Dictionary = {}
	## 这个房间的数据
	var sub_room_coords_passageway_data : Dictionary = {}
	
	func _init(
		tilemap: TileMap, 
		room_block_size: Vector2i, 
		separation: Vector2i = Vector2i(0,0),
		depth: int = 3	# 检测深度，如果这个深度内存在其他单元格，则记作是个不通过的路口
	):
		self.tilemap = tilemap
		self.room_block_size = room_block_size
		self.separation = separation
		
		var offset : Vector2i = room_block_size + separation
		
		# 地图行列块
		var map_size : Vector2i = (tilemap.get_used_rect().size + separation) / offset
		if((tilemap.get_used_rect().size + separation) % offset) > Vector2i.ONE:
			map_size += Vector2i.ONE
		var map_rect : Rect2i = Rect2i(Vector2.ZERO, map_size)
		
		# 遍历每个格子数据
		var sub_room_block_data_list : Array = []
		FuncUtil.for_rect(map_rect, func(column_row: Vector2i):
			var rect = Rect2i(column_row * offset, room_block_size)
			var data_list : Array[TileMapUtil.CellItemData] = TileMapUtil.get_cell_data_by_rect(tilemap, rect)
			if not data_list.is_empty():
				for data in data_list:
					# 去除间隔和偏移
					data.coords -= column_row * offset
				sub_room_block_data_list.append(data_list)
				# 添加坐标
				exists_sub_room_coords.append(column_row)
		)
		
		# 房间存在这个可通行的路径的方向
		for dir in [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]:
			dir_to_sub_room_coords[dir] = []
		
		# 这个房间块的方向的数据
		for coords in exists_sub_room_coords:
			var passageway_data : Dictionary = {}
			sub_room_coords_passageway_data[coords] = passageway_data
			
			# 可通行的路径的几个方向
			var dir_coords_list_map : Dictionary = TileMapUtil.find_passageway(
				tilemap, [0], Rect2i(coords * offset, room_block_size)
			)
			for dir in dir_coords_list_map.keys():
				var coords_list : Array[Vector2i] = dir_coords_list_map[dir]
				# 获取出口起始和结束的点坐标
				var valid_number : int = 0
				var added_list : Array[Dictionary] = []
				var conn_data_list = TileMapUtil.get_connected_cell(tilemap, coords_list, 0)
				for conn_data in conn_data_list:
					var from : Vector2i = conn_data['from']
					var to : Vector2i = conn_data['to']
					var center : Vector2i = MathUtil.get_median_value(from, to)
					if TileMapUtil.is_on_depth(tilemap, center, dir, depth, [0]):
						dir_to_sub_room_coords[dir].append(coords)
						# 记录这个出口路径的数据
						conn_data['center'] = center
						conn_data['list'] = coords_list
						conn_data['direction'] = dir
						added_list.append(conn_data)
				
				# 这个方向可通行的数据
				passageway_data[dir] = added_list
		
		# 记录这些方向都有的房间
		for directions in FuncUtil.combination(MathUtil.get_four_directions_i()):
			dir_hash_to_room_coords[DataUtil.as_set_hash(directions)] = []
		for coords in sub_room_coords_passageway_data:
			# 这些方向可通行的路径数据
			var passageway_data : Dictionary = sub_room_coords_passageway_data[coords]
			passageway_data = FuncUtil.filter(passageway_data, func(entry): return not entry.value.is_empty())
			var passageway_directions : Array = passageway_data.keys()
			dir_hash_to_room_coords[DataUtil.as_set_hash(passageway_directions)].append(coords)
	
	## 获取所有房间坐标
	func get_all_sub_rooms_coords() -> Array:
		return exists_sub_room_coords
	
	# 是否有这个方向的通行方向
	func has_passageway(coords: Vector2i, direction: Vector2i) -> bool:
		return Array(dir_to_sub_room_coords.get(direction, [])).has(coords)
	
	## 获取这些方向的房间列表
	func get_rooms_by_directions(directions: Array[Vector2i]) -> Array[Vector2i]:
		var dir_hash : int = DataUtil.as_set_hash(directions)
		return Array(dir_hash_to_room_coords.get(dir_hash, []), TYPE_VECTOR2I, "", null)
	
	## 获取随机房间位置
	func get_random_room_coords() -> Vector2i:
		return exists_sub_room_coords.pick_random()
	
	## 获取所有房间块的每个方向的通行数据
	func get_all_passageway_data() -> Array[Dictionary]:
		return Array(sub_room_coords_passageway_data.values(), TYPE_DICTIONARY, "", null)
	
	## 获取这个房间的通行数据
	func get_passageway_data(coords: Vector2i) -> Dictionary:
		return sub_room_coords_passageway_data.get(coords, {})
		




## 九宫格房间的每个块的数据
class NineRoomBlockItemData:
	## 生成这个房间时的索引
	var index : int = -1
	## 在原地图中的位置
	var block_coords : Vector2i = MathUtil.VECTOR2I_MAX
	## 在九宫格中的位置
	var nine_coords : Vector2i = MathUtil.VECTOR2I_MAX
	## 周围可通行的方向
	var directions : Array[Vector2i] = []
	
	##		【暂未使用】
	##
	## 放置规则，这个位置是否可以放置数据
	##[br][code]coords[/code] 单元格中的位置
	##[br][code]all[/code] 其他单元格的数据
	##[br]（可以看做是一个“规则”的数据，如果条件成立则设置这个房间）
	##[br]如果这个规则部分设计好了，则可以将这个类的名称更改为 DataRule）
	##[br]然后添加一个生成逻辑，在逻辑成立之后下一步向哪里移动，设置哪个位置）
	##[br]最后生成的时候，写个 Generator（生成器）传入这两个类对象进行生成
	##这里的数据也改为 TileMap 上每个表格的数据，然后有个“额外数据”字典类型记录其他数据
	func check(coords: Vector2i, all: Dictionary) -> bool:
		return true
	


## 九宫格房间数据生成
class NineGridRoomDataGenerator:
	
	## 九宫格数据
	var nine_data : Dictionary = {}
	## 九宫格四周所有可通行方向
	var nine_base_passage_direction : Dictionary
	
	func _init(start_pos: Vector2i):
		assert(Rect2i(-1, -1, 3, 3).has_point(start_pos), "x 和 y 值需要在 [-1, 1] 之间")
		
		# 九个方向数据
		var default : Dictionary = DataUtil.singleton("NineGridRoomDataGenerator_nine_directions", func():
			var data = {}
			for x in [-1, 0, 1]:
				for y in [-1, 0, 1]:
					data[Vector2i(x, y)] = Array([], TYPE_VECTOR2I, "", null)
			for x in [-1, 0, 1]:
				for y in [-1, 0, 1]:
					var coords : Vector2i = Vector2i(x, y)
					for direction in [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]:
						if data.has(coords + direction):
							data[coords].append(direction)
			return data
		)
		nine_base_passage_direction = default.duplicate(true)
		
		# 第一个开始位置
		var first_coords : Vector2i = start_pos
		var first_directions = get_nine_directions(first_coords)
		add_room_data(first_coords, first_directions, 0)
		
		# 广度优先搜索进行路径移动
		var index := DataUtil.get_ref_data(1)
		FuncUtil.path_move(first_coords, MathUtil.get_four_directions_i()
		, func(coords: Vector2i):
			# 可移动到这个位置时
			if is_can_move_to.call(coords):
				
				# 获取房间的周围可移动方向
				var around_directions : Array[Vector2i] = get_nine_directions(coords)
				for direction in around_directions.duplicate():
					if not is_can_passable_direction(coords, direction):
						around_directions.erase(direction)
				
				# 添加房间数据
				add_room_data(coords, around_directions, index.get_value())
				index.value += 1
				
				return true
			return false
		)
	
	## 获取生成的九宫格所有数据
	func get_all_nine_data() -> Dictionary:
		return nine_data
	
	## 获取这个单元格中的数据
	func get_nine_data(coords: Vector2i) -> NineRoomBlockItemData:
		assert(nine_data.has(coords), "没有这个单元格中的数据")
		return nine_data[coords]
	
	## 获取九宫格中其中坐标的数据
	func get_nine_directions(coords: Vector2i) -> Array[Vector2i]:
		return nine_base_passage_direction[coords].duplicate()
	
	## 添加房间数据
	func add_room_data(nine_coords: Vector2i, directions: Array[Vector2i], index: int) -> void:
		var item = NineRoomBlockItemData.new()
		item.nine_coords = nine_coords
		item.directions = directions
		item.index = index
		nine_data[nine_coords] = item 
	
	## 这个位置的九宫格是否有数据
	func has_data(nine_coords: Vector2i) -> bool:
		return nine_data.has(nine_coords)
	
	## 这个方向是否是可通行的
	func is_can_passable_direction(current_coords: Vector2i, to_direction: Vector2i) -> bool:
		var to_coords : Vector2i = current_coords + to_direction
		if has_data(to_coords):
			var this_around_data : NineRoomBlockItemData = get_nine_data(to_coords)
			for direction in this_around_data.directions:
				# 存在有通往此位置的方向，则可通行
				if direction * -1 == to_direction:
					return true
			return false
		else:
			return true
	
	## 是否可以移动到这个坐标
	func is_can_move_to(coords: Vector2i) -> bool:
		return not nine_data.has(coords) and Rect2i(-1, -1, 3, 3).has_point(coords)


## 随机九宫格房间生成器
class NineRoomGenerator:
	
	var room_block_map_data : RoomBlockMapData
	var nine_grid_gene : NineGridRoomDataGenerator
	
	## 生成到这个 TileMap 上
	static func generate_by_params(
		# 从这个 TileMap 获取房间块
		from_rooms: TileMap, 
		# 每个房间块地图的大小
		room_block_size: Vector2i, 
		# 获取地图时的空白间隔坐标格数
		separation: Vector2i = Vector2i(0,0), 
		# 生成到的 TileMap
		to_tilemap: TileMap = null, 
		# 生成的地图到 TileMap 上偏移的坐标
		to_room_offset: Vector2i = Vector2i(0,0)
	) -> NineRoomGenerator:
		return generate_by_data(
			RoomBlockMapData.new(from_rooms, room_block_size, separation, 2),
			NineGridRoomDataGenerator.new(MathUtil.get_eight_directions_i().pick_random()),
			to_tilemap,
			to_room_offset,
		)
	
	static func generate_by_data(
		room_block_map_data : RoomBlockMapData, 
		# 生成的九宫格数据
		nine_grid_gene : NineGridRoomDataGenerator,
		# 单元格生成到这个 TileMap 上
		to_tilemap: TileMap,
		# 生成的地图到 TileMap 上偏移的坐标
		to_room_offset: Vector2i = Vector2i(0,0)
	) -> NineRoomGenerator:
		var generator := NineRoomGenerator.new()
		generator.room_block_map_data = room_block_map_data
		generator.nine_grid_gene = nine_grid_gene
		
		# 开始生成到 tilemap 上
		var from_rooms : TileMap = room_block_map_data.tilemap
		var room_block_size : Vector2i = room_block_map_data.room_block_size
		var separation : Vector2i = room_block_map_data.separation
		if to_tilemap != null:
			FuncUtil.for_dict(generator.nine_grid_gene.get_all_nine_data(), func(coords: Vector2i, data: NineRoomBlockItemData):
				var directions : Array[Vector2i] = data.directions
				if not directions.is_empty():
					data.block_coords = room_block_map_data.get_rooms_by_directions(directions).pick_random()
					# 生成到 TileMap 上
					var gene_to_coords : Vector2i = data.nine_coords * (room_block_size + Vector2i.ONE)
					TileMapUtil.copy_cell_to(
						from_rooms, Rect2i(data.block_coords * (room_block_size + separation), room_block_size),
						to_tilemap, Rect2i(gene_to_coords + to_room_offset, room_block_size),
					)
			)
		return generator
	


## 切分地图房间，生成每个块的房间数据的数据对象。这样就可以根据单元格坐标获取对应区块的 Tile 数据了
static func cut_map_room(
	rooms: TileMap, 
	room_block_size: Vector2i, 
	separation: Vector2i = Vector2i.ZERO, 
	depth: int = 3
) -> RoomBlockMapData:
	return RoomBlockMapData.new(rooms, room_block_size, separation, 2)


##  生成九宫格房间生成器
##[br]
##[br][code]start_pos[/code]  开始位置
##[br][code]return[/code]  返回生成器实例
static func nine_grid_room_data_generator(start_pos: Vector2i) -> NineGridRoomDataGenerator:
	return NineGridRoomDataGenerator.new(start_pos)

