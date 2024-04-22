#============================================================
#    Tilemap Util
#============================================================
# - datetime: 2023-02-14 19:48:46
#============================================================
## TileMap 工具类
##
##一些处理 TileMap 数据的功能
class_name TileMapUtil

# tile 和 cell 的区别
# - tile（瓦片）：方法名或变量名带有 “tile” 的可以认为是瓦片的 ID 的值的数据
# - cell（单元格）：获取瓦片的所在行和列的坐标位置。是 Vector2i 类型的数据


## 获取这层的所有瓦片数据。坐标对应地图图片ID和地图集坐标
static func get_cells(tilemap: TileMap, layer: int) -> Dictionary:
	var data : Dictionary = {}
	FuncUtil.for_rect(tilemap.get_used_rect(), func(coordinate: Vector2i):
		var source_id = tilemap.get_cell_source_id(layer, coordinate)
		var atlas_coord = tilemap.get_cell_atlas_coords(layer, coordinate)
		if source_id != -1:
			data[coordinate] = {
				"source_id": source_id,
				"atlas_coord": atlas_coord,
			}
	)
	return data


## 获取 TileMap 可通行路口
##[br]
##[br][code]tilemap[/code]  获取数据的 [TileMap] 对象
##[br][code]layers[/code]  获取这些层的数据。如果为空数组，则获取判断全部的层
##[br]
##[br] 返回以下结构的数据，列表中是对应方向的周围没有瓦片的单元格坐标列表，这个列表是 [Vector2i]
##类型的单元格坐标
##[codeblock]
##{
##    Vector.LEFT: [],
##    Vector.UP: [],
##    Vector.RIGHT: [],
##    Vector.DOWN: [],
##}
##[/codeblock]
##[br]使用 [method get_connected_cell] 方法处理返回的数据的每个方向的列表值，
##判断这些点之间没有障碍的开始和结束的坐标数据
static func find_passageway(
	tilemap: TileMap, 
	layers: Array[int] = [], 
	rect: Rect2i = Rect2i()
) -> Dictionary:
	var door_data : Dictionary = {
		Vector2i.LEFT: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.UP: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.RIGHT: Array([], TYPE_VECTOR2I, "", null),
		Vector2i.DOWN: Array([], TYPE_VECTOR2I, "", null),
	}
	
	if rect == Rect2i():
		rect = tilemap.get_used_rect()
	if layers.is_empty():
		layers = get_layers(tilemap)
	
	var left_column : int = rect.position.x
	var right_column : int = rect.end.x
	var top_row : int = rect.position.y
	var bottom_row : int = rect.end.y
	var coordinate : Vector2i
	
	# 每列
	for x in range(left_column, right_column):
		coordinate = Vector2i(x, top_row)
		for layer in layers:
			if (tilemap.get_cell_source_id(layer, coordinate) == -1
				and (
					tilemap.get_cell_source_id(layer, coordinate + Vector2i.LEFT) > -1
					or tilemap.get_cell_source_id(layer, coordinate + Vector2i.RIGHT) > -1
				)
			):
				door_data[Vector2i.UP].append(coordinate)
				break
		
		coordinate = Vector2i(x, bottom_row)
		for layer in layers:
			if (tilemap.get_cell_source_id(layer, coordinate) == -1
				and (
					tilemap.get_cell_source_id(layer, coordinate + Vector2i.LEFT) > -1
					or tilemap.get_cell_source_id(layer, coordinate + Vector2i.RIGHT) > -1
				)
			):
				door_data[Vector2i.DOWN].append(coordinate)
				break
		
	# 每行
	for y in range(top_row, bottom_row):
		coordinate = Vector2i(left_column, y)
		for layer in layers:
			if (tilemap.get_cell_source_id(layer, coordinate) == -1
				and (tilemap.get_cell_source_id(layer, coordinate + Vector2i.UP) > -1
					or tilemap.get_cell_source_id(layer, coordinate + Vector2i.DOWN) > -1
				)
			):
				door_data[Vector2i.LEFT].append(coordinate)
				break
		
		coordinate = Vector2i(right_column, y)
		for layer in layers:
			if (tilemap.get_cell_source_id(layer, coordinate) == -1
				and (tilemap.get_cell_source_id(layer, coordinate + Vector2i.UP) > -1
					or tilemap.get_cell_source_id(layer, coordinate + Vector2i.DOWN) > -1
				)
			):
				door_data[Vector2i.RIGHT].append(coordinate)
				break
	
	return door_data


##  单元格是连通的
##[br]
##[br][code]tilemap[/code]  TileMap 对象
##[br][code]from[/code]  开始的坐标
##[br][code]to[/code]  到达的坐标
##[br][code]layer[/code]  所在的层
static func cell_is_connected(tilemap: TileMap, from: Vector2i, to: Vector2i, layer: int = 0) -> bool:
#	if (from - to).abs() == Vector2i.ONE:
#		return true
	var start = Vector2(from)
	var end = Vector2(to)
	var direction = start.direction_to(end)
	for step in floor(start.distance_to(end) - 1.0):
		start += direction
		var id = tilemap.get_cell_source_id(layer, Vector2i(start.round()))
		if id != -1:
			return false
	return true


##  获取这组点列表可以互相连接的点，两个点之间没有其他瓦片
##[br]
##[br][code]tilemap[/code]  tilemap对象
##[br][code]points[/code]  点列表
##[br][code]layer[/code]  所在的层
##[br]
##[br]返回以下结构的数据列表
##[codeblock]
##{
##    "from": Vector2, 
##    "to": Vector2,
##}
##[/codeblock] 
static func get_connected_cell(tilemap: TileMap, points: Array, layer: int = 0) -> Array[Dictionary]:
	if points.size() < 2:
		return []
	var list : Array[Dictionary]= []
	for i in points.size() - 1:
		for j in range(i + 1, points.size()):
			if cell_is_connected(tilemap, points[i], points[j], layer):
				list.append({
					"from": points[i],
					"to": points[j],
				})
	
	for idx in range(list.size() - 1, -1, -1):
		var data := Dictionary(list[idx])
		if (data['from'] == data['to']):
			list.remove_at(idx)
	
	return list


## 获取两边没有瓦片的单元格
static func get_between_no_tile_cell(tilemap: TileMap, coordinate: Vector2i, layer: int = 0, max_height: int = 1, max_width: int = 1) -> Array[Vector2i]:
	var id = tilemap.get_cell_source_id(layer, coordinate)
	var no_tiles : Array[Vector2i] = []
	if id != -1:
		for width in max_width:
			var left : Vector2i = coordinate + Vector2i(-width, 0)
			var right : Vector2i = coordinate + Vector2i(width, 0)
			for i in (max_height + 1):
				left -= Vector2i(0, i)
				if tilemap.get_cell_source_id(layer, left) > -1:
					no_tiles.append(left)
				right -= Vector2i(0, i)
				if tilemap.get_cell_source_id(layer, right) > -1:
					no_tiles.append(right)
	return no_tiles


## 获取这个坐标点两边的立足点。会返回两个项的数组，第一个为左边的点，第二个为右边的点，若为 null，则代表没有
static func get_foothold_cell(tilemap: TileMap, coordinate: Vector2i, layer: int = 0) -> Array:
	var used_rect = tilemap.get_used_rect()
	var left : Vector2i
	var right : Vector2i
	var coords : Array = [null, null]
	
	# 左。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(layer, coordinate + Vector2i(-1, -1)) == -1
		and tilemap.get_cell_source_id(layer, coordinate + Vector2i(-1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			left = coordinate + Vector2i(-1, i)
			if tilemap.get_cell_source_id(layer, left) != -1:
				coords[0] = left
				break
		
	# 右。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(layer, coordinate + Vector2i(1, -1)) == -1
		and tilemap.get_cell_source_id(layer, coordinate + Vector2i(1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			right = coordinate + Vector2i(1, i)
			if tilemap.get_cell_source_id(layer, right) != -1:
				coords[1] = right
				break
	
	return coords


## 获取可接触到的单元格点
static func get_touchable_coordinates(tilemap: TileMap, coordinate: Vector2i, touchable_height: int, touchable_width: int, layer: int = 0) -> Array:
	var list : Array = [null, null]
	
	# 头顶不能有碰撞的单元格
	for i in range(1, touchable_height + 1):
		if tilemap.get_cell_source_id(layer, coordinate + Vector2i(0, -i)) != -1:
			return list
		
	# 从中心向两边扩散，那一边的某列有，那这边是这个单元格可接触
	var left : Vector2i
	var right : Vector2i
	for y in range(1, touchable_height + 1):
		for x in range(1, touchable_width + 1):
			if list[0] == null:
				left = coordinate + Vector2i(-x, -y)
				if (tilemap.get_cell_source_id(layer, left) > -1
					and tilemap.get_cell_source_id(layer, left + Vector2i.UP) == -1
				):
					list[0] = left
			
			if list[1] == null:
				right = coordinate + Vector2i(x, -y)
				if (tilemap.get_cell_source_id(layer, right) > -1
					and tilemap.get_cell_source_id(layer, right + Vector2i.UP) == -1
				):
					list[1] = right
			
			if list[0] != null and list[1] != null:
				break
		
		if list[0] != null and list[1] != null:
			break
	
	return list


## 瓦片替换为节点
static func replace_tile_as_node_by_scene(tilemap: TileMap, layer: int, coordinate: Vector2i, scene: PackedScene) -> Node:
	tilemap.set_cell(layer, coordinate, -1, Vector2(0, 0))
	
	# 替换场景节点
	var node = scene.instantiate()
#	node.z_index = -10
	tilemap.add_child(node)
	node.global_position = tilemap.global_position + Vector2(tilemap.tile_set.tile_size * coordinate) 
	return node


## 获取是个地板的单元格
##[br]
##[br][code]tilemap[/code]  数据来源 TileMap
##[br][code]layer[/code]  所在层
##[br][code]ids[/code]  这个单元格的 ID
##[br][code]atlas_coords[/code]  这个单元格图片的坐标
##[br][code]return[/code]  返回符合条件的单元格
static func get_ground_cells(
	tilemap: TileMap, 
	layer: int, 
	ids: Array[int] = [], 
	atlas_coords: Array[Vector2i] = []
) -> Array[Vector2i]:
	var list : Array[Vector2i] = []
	if ids.is_empty() and atlas_coords.is_empty():
		return tilemap.get_used_cells(layer)
	
	for coordinate in tilemap.get_used_cells(layer):
		if ((ids.is_empty() or tilemap.get_cell_source_id(layer, coordinate) in ids)
			and (atlas_coords.is_empty() or tilemap.get_cell_atlas_coords(layer, coordinate) in atlas_coords)
		):
			if tilemap.get_cell_source_id(layer, coordinate + Vector2i.UP) == -1:
				list.append(coordinate)
	return list


## 获取 TileMap 的中心位置
static func get_global_center(tilemap: TileMap) -> Vector2:
	return tilemap.global_position + Vector2(tilemap.get_used_rect().size / 2 * tilemap.tile_set.tile_size)


## 是否存在这个 ID
static func is_exists_id(tilemap: TileMap, idx: int) -> bool:
	return tilemap.tile_set != null and tilemap.tile_set.get_source(idx) != null


## 添加贴图
##[br]
##[br][code]tilemap[/code]  添加到的 [TileMap]
##[br][code]texture[/code]  添加的图片
##[br][code]atlas_source_id_override[/code]  要覆盖掉的之前的ID。如果为 [code]-1[/code]，则为新增
static func add_texture(
	tilemap: TileMap, 
	texture: Texture2D, 
	atlas_source_id_override: int = -1
) -> void:
	var tile_set : TileSet
	if tilemap.tile_set == null:
		tilemap.tile_set = TileSet.new()
	tile_set = tilemap.tile_set
	
	# 添加 Texture
	var source : TileSetAtlasSource
	if tile_set.has_source(atlas_source_id_override):
		source = tile_set.get_source(atlas_source_id_override)
		source.texture = texture
	else:
		source = TileSetAtlasSource.new()
		source.texture = texture
		source.create_tile(Vector2i())
		tile_set.add_source(source, atlas_source_id_override)

## 获取这个 [TileMap] 的所有层索引
static func get_layers(tilemap: TileMap) -> Array[int]:
	return Array(range(tilemap.get_layers_count()), TYPE_INT, &"", null)

## 是否有数据
static func has_cell_data(tilemap: TileMap, coords: Vector2i, layers: Array[int]):
	for layer in layers:
		if tilemap.get_cell_source_id(layer, coords) != -1:
			return true
	return false

## 这块区域是否有瓦片
static func has_cell_data_by_rect(tilemap: TileMap, rect: Rect2i, layers: Array[int] = [], use_proxies: bool = false) -> bool:
	if layers.is_empty():
		layers = get_layers(tilemap)
	
	var coordinate : Vector2i
	for y in range(rect.position.y, rect.end.y + 1):
		for x in range(rect.position.x, rect.end.x + 1):
			coordinate = Vector2i(x, y)
			for layer in layers:
				if tilemap.get_cell_source_id(layer, coordinate, use_proxies) != -1:
					return true
	return false


##  获取这片区域的瓦片数据列表
##[br]
##[br][code]tilemap[/code]  地图
##[br][code]rect[/code]  获取区域的区域
##[br][code]layer[/code]  所在层
##[br][code]use_proxies[/code]  如果 [code]use_proxies[/code] 为 [code]false[/code]，
##则忽略 [TileSet]的 tile 代理。请参见 [method TileSet.map_tile_proxy]
##[br][code]return[/code] 返回的数据结构类似如下结构：
##[codeblock]
##{
##    "layer": 0,
##    "coords": Vector2i(),
##    "source_id": 0,
##    "alternative_tile": -1,
##    "atlas_coords": Vector2i(),
##}
##[/codeblock]
static func get_cell_data_by_rect(
	tilemap: TileMap, 
	rect: Rect2i, 
	layers: Array[int] = [], 
	use_proxies: bool = false
) -> Array[CellItemData]:
	if layers.is_empty():
		layers = get_layers(tilemap)
	
	var list : Array[CellItemData] = []
	FuncUtil.for_rect(rect, func(coordinate: Vector2i):
		var source_id : int = -1
		for layer in layers:
			source_id = tilemap.get_cell_source_id(layer, coordinate, use_proxies)
			if source_id != -1:
				list.append_array(get_cell_data(tilemap, coordinate, layers, use_proxies))
				break
	)
	return list


## 这个单元格的数据
class CellItemData:
	var layer : int
	var coords : Vector2i
	var source_id : int
	var atlas_coords : Vector2i
	var alternative_tile : int
	var use_proxies : bool
	
	func _init(data: Dictionary = {}):
		if not data.is_empty():
			JsonUtil.set_property_by_dict(data, self)
	
	func _to_string():
		return JsonUtil.object_to_json(self, "    ")


##  获取这个坐标的单元格的所有数据
##[br]
##[br][code]tilemap[/code]  获取的 tilemap
##[br][code]coordinate[/code]  所在单元格的坐标
##[br][code]layers[/code]  要获取的层级的数据。如果为空，则默认获取全部的层级的数据
##[br][code]use_proxies[/code]  获取代理的数据
static func get_cell_data(
	tilemap: TileMap, 
	coordinate: Vector2i, 
	layers: Array[int] = [], 
	use_proxies: bool = false 
) -> Array[CellItemData]:
	var list : Array[CellItemData] = []
	if layers.is_empty():
		layers = get_layers(tilemap)
	var item : CellItemData
	for layer in layers:
		item = CellItemData.new()
		item.layer = layer
		item.use_proxies = use_proxies
		item.coords = coordinate
		item.source_id = tilemap.get_cell_source_id(layer, coordinate, use_proxies)
		item.atlas_coords = tilemap.get_cell_atlas_coords(layer, coordinate, use_proxies)
		item.alternative_tile = tilemap.get_cell_alternative_tile(layer, coordinate, use_proxies)
		list.append(item)
	return list


## 设置单元格的数据
##[br]
##[br][code]tilemap[/code]  要设置的 [TileMap]
##[br][code]data[/code]  设置的数据。所需的数据结构为 [method set_cell_data] 方法中的结构
static func set_cell_data(tilemap: TileMap, data: Dictionary) -> void:
	set_cell(
		tilemap, 
		data.get("coords", Vector2i.ZERO),
		data.get("source_id", 0),
		data.get("atlas_coords", Vector2i.ZERO),
		data.get("layer", 0),
	)

## 设置这个单元格位置的数据
static func set_cell(
	tilemap: TileMap,
	coords: Vector2i, 
	source_id: int, 
	atlas_coords: Vector2i = Vector2i.ZERO, 
	layer: int = 0,
):
	tilemap.set_cell(layer, coords, source_id, atlas_coords)


## 擦除这个单元格
static func clear_cell(tilemap: TileMap, coords: Vector2i, layers: Array[int] = []):
	if layers.is_empty():
		layers = get_layers(tilemap)
	for layer in layers:
		tilemap.set_cell(layer, coords, -1, Vector2i(-1, -1))


##  复制 cell 数据到 TileMap 上
##[br]
##[br][code]from_tilemap[/code]  从这个 [TileMap] 中获取数据
##[br][code]from_rect[/code]  获取这个区域的范围的数据
##[br][code]to_tilemap[/code]  复制到这个 [TileMap] 上
##[br][code]to_rect[/code]  复制到这个区域范围内。如果为 Rect2i(0,0,0,0) 则为 from_rect 参数的值
##[br][code]layers[/code]  复制这些层的数据，如果参数为空，则默认获取所有层的数据
##[br][code]cell_filter[/code]  过滤数据方法。这个参数需要有一个 [Dictionary] 
##类型的参数接受这个单元格上数据，并返回一个 [bool] 类型的值返回是否需要这个数据，如果返回 
##[code]true[/code] 则添加，否则不添加
static func copy_cell_to(
	from_tilemap: TileMap, 
	from_rect: Rect2i, 
	to_tilemap: TileMap, 
	to_rect: Rect2i = Rect2i(), 
	layers: Array[int] = [], 
	cell_filter: Callable = Callable()
):
	assert(from_rect.size != Vector2i.ZERO, "from_rect 参数值的大小必须要超过 0！")
	if to_rect == Rect2i():
		to_rect = from_rect
	if layers.is_empty():
		layers = get_layers(from_tilemap)
	
	# 获取数据
	var dict : Dictionary = {}
	if cell_filter.is_valid():
		FuncUtil.for_rect_i(from_rect, func(from_coords: Vector2i):
			var list : Array[CellItemData] = []
			for data in get_cell_data(from_tilemap, from_coords, layers):
				if cell_filter.call(data):
					list.append(data)
			if not list.is_empty():
				dict[from_coords] = list
		)
	else:
		FuncUtil.for_rect_i(from_rect, func(from_coords: Vector2i):
			dict[from_coords] = get_cell_data(from_tilemap, from_coords, layers)
		)
	
	# 复制到另一个 TileMap 上
	var offset : Vector2i = from_rect.position - to_rect.position
	FuncUtil.for_rect_i(to_rect, func(to_coords: Vector2i):
		var from_coords : Vector2i = to_coords + offset
		if dict.has(from_coords):
			var list : Array[CellItemData] = dict[from_coords]
			for data in list:
				if data.layer < to_tilemap.get_layers_count():
					var cell_coord : Vector2i = data.coords - offset
					to_tilemap.set_cell(data.layer, cell_coord, data.source_id, data.atlas_coords)
		else:
			printerr("没有这个位置：", from_coords)
	)


##  复制所有 Cell 到另一个 TileMap 上
##[br]
##[br][code]from[/code]  从这个 TileMap 上复制数据
##[br][code]to[/code]  设置到这个 TileMap 上
##[br][code]offset_coord[/code]  偏移的坐标位置
static func copy_all_cell_to(from: TileMap, to: TileMap, offset_coord: Vector2i = Vector2i.ZERO):
	for layer in from.get_layers_count():
		for coords in from.get_used_cells(layer):
			to.set_cell(layer, coords + offset_coord, 
				from.get_cell_source_id(layer, coords), 
				from.get_cell_atlas_coords(layer, coords), 
				from.get_cell_alternative_tile(layer, coords), 
			)


## 是否达到深度
##[br]
##[br]这个深度的方向一行货列中没有其他瓦片数据时返回 [code]true[/code]，否则返回 [code]false[/code]
##[br]
##[br][code]tilemap[/code]  判断的 [TileMap]
##[br][code]coords[/code]  从这个坐标开始
##[br][code]from_direction[/code]  这个方向为出口方向
##[br][code]layers[/code]  判断所在的层
##[br][code]depth[/code]  判断深度
static func is_on_depth(
	tilemap: TileMap, 
	coords: Vector2i, 
	from_direction: Vector2i, 
	depth : int,
	layers: Array[int] = [],
) -> bool:
	assert(depth > 0, "深度必须要超过0")
	
	var move_direction : Vector2i = from_direction * -1
	for i in depth:
		coords += move_direction
		if TileMapUtil.has_cell_data(tilemap, coords, layers):
			return false
	return true


## 获取两点之间的连接线
static func get_connect_line_points(from_coords: Vector2i, to_coords: Vector2i) -> Array[Vector2i]:
	var min_coords := Vector2i(MathUtil.get_min_xy([from_coords, to_coords]))
	var max_coords := Vector2i(MathUtil.get_max_xy([from_coords, to_coords]))
	var rect := Rect2i(min_coords, (max_coords - min_coords).abs())
	if rect.size.x == 0:
		rect.size.x = 1
	if rect.size.y == 0: 
		rect.size.y = 1
	
	var direction := Vector2(to_coords - from_coords).normalized()
	var tmp_coords := Vector2(from_coords)
	var tmp_coords_i := Vector2i(from_coords)
	var list : Array[Vector2i]
	while true:
		tmp_coords += direction
		tmp_coords_i = Vector2i(tmp_coords)
		if rect.has_point(tmp_coords_i):
			list.append(tmp_coords_i)
		else:
			if list.is_empty():
				printt(rect, tmp_coords_i, direction)
			if not list.is_empty() and list.back() != to_coords:
				list.append(to_coords)
			break
	return list


## 如果其中没有存在障碍物则返回 -1
static func ray_cell_coords(
	tilemap: TileMap, 
	from: Vector2i, 
	direction: Vector2, 
	max_length: int,
	layers : Array[int]
) -> int:
	var length = 0
	var tmp_from = Vector2(from) + direction.sign()
	var result = -1
	while (length < max_length - 1):
		for layer in layers:
			result
			result &= (
				tilemap.get_cell_source_id(layer, Vector2i(tmp_from))
				| tilemap.get_cell_source_id(layer, Vector2i(tmp_from.ceil()) )
			)
		if result != -1:
			break
		
		tmp_from += direction
		# 存在有障碍物
		length += 1
	return result


## 射线射向目标位置
##[br]
##[br][code]coords[/code]  所在位置
##[br][code]direction[/code]  检测方向
##[br][code]length[/code]  长度
##[br][code]layers[/code]  检测层
##[br][code]return[/code]  返回检测到的瓦片的坐标位置，如果没有检测到瓦片，则返回 [constant MathUtil.VECTOR2I_MAX]
static func ray_to(
	tilemap: TileMap,
	coords: Vector2i,
	direction: Vector2,
	length: float = INF,
	layers : Array[int] = []
) -> Vector2i:
	if layers.is_empty():
		layers = get_layers(tilemap)
	var rect := tilemap.get_used_rect()
	var tmp_coords := Vector2(coords)
	var tmp_coords_i := Vector2i(coords)
	
	var i : int = -1
	while true:
		i += 1
		if i >= length:
			break
		tmp_coords += direction
		tmp_coords_i = Vector2i(tmp_coords)
		if not rect.has_point(tmp_coords_i):
			break
		if has_cell_data(tilemap, tmp_coords_i, layers):
			return tmp_coords_i
	return MathUtil.VECTOR2I_MAX


## 扫描地面砖块
##[br]
##[br][code]tilemap[/code]  
##[br][code]in_layers[/code]  在 used_cells 中的单元坐标列表之上是否有这些层的单元格
##[br][code]used_cells[/code]  这些正在使用的单元格列表
##[br][code]return[/code]  返回扫描到的单元格列表
static func scan_ground(tilemap: TileMap, in_layers: Array[int], used_cells: Array[Vector2i]) -> Array[Vector2i]:
	if in_layers.is_empty():
		in_layers = get_layers(tilemap)
	
	var used_rect = tilemap.get_used_rect()
	var coords_list : Array[Vector2i] = []
	for coords in used_cells:
		if used_rect.has_point(coords + Vector2i.UP):
			if not TileMapUtil.has_cell_data(tilemap, coords + Vector2i.UP, in_layers):
				coords_list.append(coords)
	return coords_list


## 返回给定参数的所有元格的位置
static func get_used_cells(
	tilemap: TileMap, 
	source_ids: Array[int], 
	atlas_coords_list: Array[Vector2i],
	layers: Array[int] = [], 
) -> Array[Vector2i]:
	if layers.is_empty():
		layers = get_layers(tilemap)
	
	var data = {}
	for layer in layers:
		for source_id in source_ids: 
			for atlas_coords in atlas_coords_list:
				for cell in tilemap.get_used_cells_by_id(layer, source_id, atlas_coords):
					data[cell] = []
	return Array(data.keys(), TYPE_VECTOR2I, "", null)


## 获取整个地图实际矩形像素大小
static func get_rect(tilemap: TileMap) -> Rect2:
	var rect = tilemap.get_used_rect()
	rect.position *= tilemap.tile_set.tile_size
	rect.size *= tilemap.tile_set.tile_size
	rect.position += Vector2i(tilemap.global_position)
	return rect


## 获取全部外侧瓦片坐标列表
static func get_all_edge_coords_list(tile_map: TileMap, layer: int = 0) -> Array:
	var coords_list = []
	var visited = {}
	var rect = tile_map.get_used_rect().grow(1)
	var tmp_coords
	var last_coords_list = [rect.position] # 从左上角第一个位置开始
	while not last_coords_list.is_empty():
		var next_coords_list = []
		for coords in last_coords_list:
			for direction in MathUtil.get_four_directions_i():
				tmp_coords = coords + direction # 移动到的位置
				if not visited.has(tmp_coords) and rect.has_point(tmp_coords):
					# 判断移动到的位置(tmp_coords)是否是墙
					if tile_map.get_cell_source_id(layer, tmp_coords) == -1:
						next_coords_list.append(tmp_coords)
					else:
						coords_list.append(tmp_coords)
					visited[tmp_coords] = null
		last_coords_list = next_coords_list
		next_coords_list = []
	return coords_list


## 获取全部外侧空白瓦片坐标列表
static func get_all_edge_empty_coords_list(
	tile_map: TileMap, 
	layer: int = 0,
	grow: int = 1, # 向外扩展大小
) -> Array:
	var coords_list = []
	var visited = {}
	var rect = tile_map.get_used_rect().grow(grow)
	var tmp_coords
	var last_coords_list = [rect.position] # 从左上角第一个位置开始
	while not last_coords_list.is_empty():
		var next_coords_list = []
		for coords in last_coords_list:
			for direction in MathUtil.get_four_directions_i():
				tmp_coords = coords + direction # 移动到的位置
				if not visited.has(tmp_coords) and rect.has_point(tmp_coords):
					# 判断移动到的位置(tmp_coords)是否是墙
					if tile_map.get_cell_source_id(layer, tmp_coords) == -1:
						next_coords_list.append(tmp_coords)
						coords_list.append(tmp_coords)
					visited[tmp_coords] = null
		last_coords_list = next_coords_list
		next_coords_list = []
	return coords_list


## 获取一侧的最外侧瓦片坐标列表。这个是不太准的获取方式
static func get_edge_coords_list(tile_map: TileMap, direction: Vector2i) -> Array:
	var rect = tile_map.get_used_rect()
	var room_coords_list = []
	var coords
	match direction:
		Vector2i.LEFT:
			for y in range(rect.position.y, rect.end.y):
				for x in range(rect.position.x, rect.end.x):
					# 判断每个 y 行的外侧瓦片
					if tile_map.get_cell_source_id(0, Vector2i(x, y)) != -1:
						room_coords_list.append(Vector2i(x, y))
						break
		Vector2i.RIGHT:
			for y in range(rect.position.y, rect.end.y):
				for x in range(rect.end.x - 1, rect.position.x - 1, -1):
					# 判断每个 y 行的外侧瓦片
					if tile_map.get_cell_source_id(0, Vector2i(x, y)) != -1:
						room_coords_list.append(Vector2i(x, y))
						break
		Vector2i.UP:
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.position.y, rect.end.y):
					# 判断每个 x 列的外侧瓦片
					if tile_map.get_cell_source_id(0, Vector2i(x, y)) != -1:
						room_coords_list.append(Vector2i(x, y))
						break
		Vector2i.DOWN:
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.end.y - 1, rect.position.y - 1, -1):
					# 判断每个 x 列的外侧瓦片
					if tile_map.get_cell_source_id(0, Vector2i(x, y)) != -1:
						room_coords_list.append(Vector2i(x, y))
						break
	return room_coords_list


## 地图边缘转为多边形点，这个点都是单元格坐标点
static func tile_map_to_polygon(tilemap: TileMap) -> Array:
	# 获取边缘点
	var points = get_all_edge_coords_list(tilemap)
	# 点排序
	return __tile_map_to_polygon_sort_points(points)

static func __tile_map_to_polygon_sort_points(list) -> Array:
	var curr = list[0]
	var visited = {}
	visited[curr] = null
	var l : Array = [curr]
	var tmp
	var moved = false
	while true:
		moved = false
		for dir in [
			Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
			Vector2i(-1, -1), Vector2i(-1, 1),
			Vector2i(1, 1), Vector2i(1, -1),
		]:
			tmp = curr + dir
			if not visited.has(tmp) and list.has(tmp):
				l.append(tmp)
				curr = tmp
				visited[tmp] = null
				moved = true
				break
		if not moved:
			break
	return l
