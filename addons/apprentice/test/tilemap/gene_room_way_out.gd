#============================================================
#    Gene Room Way Out
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-06 12:37:34
# - version: 4.0
#============================================================
# 可通行的路径中心点
@tool
extends EditorScript



func _run():
	var root : Node = EditorUtil.get_edited_scene_root()
	var gene_map := root.get_node("gene") as TileMap
	
	# 获取区块数据
	var room_block_size : Vector2i = Vector2i(16, 13)
	var separation : Vector2i = Vector2i(5, 5)
	var rooms := root.get_node("rooms") as TileMap
	var room_block_map_data := MapGenerateUtil.cut_map_room(rooms, room_block_size, separation, 2)

	# 生成数据
	gene_map.clear()
	FuncUtil.for_rect_i(Rect2i(0,0,2,2), func(coords: Vector2i):
		# 生成 9 个 九宫格数据
		var start_pos : Vector2i = MathUtil.get_eight_directions_i().pick_random()
		var data_generator := MapGenerateUtil.nine_grid_room_data_generator(start_pos)
		MapGenerateUtil.NineRoomGenerator.generate_by_data(
			room_block_map_data, 
			data_generator, 
			gene_map,
			coords * (room_block_size + Vector2i.ONE) * 3
		)

	)

#	# 显示出口
#	var way_out := root.get_node("way_out") as TileMap
#	if way_out.tile_set == null:
#		var texture : Texture2D = TextureUtil.create_texture_by_color(Vector2i(16, 16), Color.ROYAL_BLUE)
#		TileMapUtil.add_texture(way_out, texture)
#	way_out.clear()
#	for passageway_data in room_block_map_data.get_all_passageway_data():
#		for direction in passageway_data:
#			var data_list : Array[Dictionary] = passageway_data[direction]
#			for data in data_list:
#				way_out.set_cell(0, data.center, 0, Vector2i(0, 0))
	
	print()
	print("[ FINISHED ] ", Time.get_datetime_string_from_system().replace("T", " "))
	print("=".repeat(50))
	
	
	var stairs := load("res://src/main/scene/environment/stairs/stairs.tscn") as PackedScene
	
	var interactive = root.get_node("interactive")
	NodeUtil.queue_free_children(interactive)
	interactive.global_position = gene_map.global_position
	
	# 替换楼梯
	var offset = gene_map.get_used_rect().position
	for coords in gene_map.get_used_cells_by_id(Const.TileLayer.INTERACTIVE, 1, Vector2i(0, 3)):
		var direction : Vector2i
		var target_coords : Vector2i
		if TileMapUtil.ray_to(gene_map, coords, Vector2i.DOWN, 1) != MathUtil.VECTOR2I_MAX:
			target_coords = TileMapUtil.ray_to(gene_map, coords, Vector2i.UP)
			direction = Vector2i.UP
		else:
			target_coords = TileMapUtil.ray_to(gene_map, coords, Vector2i.DOWN)
			direction = Vector2i.DOWN
		
		if target_coords != MathUtil.VECTOR2I_MAX:
			var instance = stairs.instantiate()
			interactive.add_child(instance)
			instance.position = gene_map.map_to_local(coords) - Vector2(0, 8) * Vector2(direction)
			
			instance.grow(direction, abs(coords.y - target_coords.y) )
	
	print('-=-----')
	
	# 扫描地面
	var used_cells : Array[Vector2i] = []
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(1, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(2, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(3, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(3, 1)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(4, 0)))
	var layers = TileMapUtil.get_layers(gene_map)
	var coords_list : Array[Vector2i] = TileMapUtil.scan_ground(gene_map, layers, used_cells)
	
	# 添加显示
	var ground = root.get_node("ground") as TileMap
	ground.clear()
	for coords in coords_list:
		ground.set_cell(0, coords + Vector2i.UP, 0, Vector2i(0, 0))
	
	# 地面装饰
	var decoration = root.get_node("decoration") as TileMap
	decoration.clear()
	for coords in coords_list:
		if randf() <= 0.25:
			decoration.set_cell(0, coords + Vector2i.UP, 5, Vector2i(randi_range(0, 3), 0))
	
	
	
	
	
