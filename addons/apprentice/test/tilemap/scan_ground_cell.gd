#============================================================
#    Scan ground Cell
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-14 00:24:49
# - version: 4.0
#============================================================
## 扫描地面瓦片
@tool
extends EditorScript



func _run():
	pass
	
	var root = EditorUtil.get_edited_scene_root()
	var gene_map = root.get_node("gene") as TileMap
	
	# 扫描地面
	var used_cells : Array[Vector2i] = []
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(1, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(2, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(3, 0)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(3, 1)))
	used_cells.append_array(gene_map.get_used_cells_by_id(0, 1, Vector2i(4, 0)))
	var coords_list : Array[Vector2i] = TileMapUtil.scan_ground(gene_map, [], used_cells)
	
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


