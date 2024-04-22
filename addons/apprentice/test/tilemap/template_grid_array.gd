#============================================================
#    Template Grid Array
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-04 20:40:06
# - version: 4.0
#============================================================
## 生成表格阵列，划分每个区块
##
##用于生成地图时，制作子地图，生成的阵列块于区分每个区域。
##模板表格 TileMap，添加个 TileMap 并选中然后直接运行这个脚本
@tool
extends EditorScript


func _run():
	
	# 获取当前选中的 TileMap 节点
	var tilemap : TileMap = GQuery.from(EditorUtil.get_selected_nodes()).first_item() as TileMap
	if tilemap == null:
		printerr("没有选中 TileMap")
		return
	
	# 添加贴图，4个颜色
	FuncUtil.foreach(FuncUtil.repeat_list(Color.WHITE, 4), func(color: Color, idx: int):
		color *= (5 - idx) * 0.2
		var texture : Texture2D = TextureUtil.create_texture_by_color(Vector2(16, 16), color)
		TileMapUtil.add_texture(tilemap, texture, idx)
	)
	
	# 开始生成
	var map_rect : Rect2i = MathUtil.rect2i(Vector2i(20, 3))
	var sub_size : Vector2i = Vector2i(16, 13)
	var offset : Vector2i = sub_size + Vector2i(5, 5)
	
	# 设置单元格4个角落进行添加
	tilemap.clear()
	FuncUtil.for_rect(map_rect, func(column_row: Vector2i):
		var four_quad = MathUtil.quadranglei(Rect2i(column_row * offset, sub_size))
		FuncUtil.foreach(four_quad, func(cell: Vector2i, idx: int):
			tilemap.set_cell(0, cell, idx, Vector2i(0, 0))
		)
	)
	
	print("[ finish ] : ", self.get_script().resource_path)

