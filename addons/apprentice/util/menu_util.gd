#============================================================
#    Menu Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-29 18:56:28
# - version: 4.0
#============================================================
## 菜单数据工具
class_name MenuUtil


class _MenuItem:
	extends Object
	
	signal pressed_menu(id: int, menu_path: String)
	
	var _path_to_menu_node : Dictionary = {}
	
	
	func _init(menu: PopupMenu, data_list: Array[Dictionary]):
		# 这个菜单已有的 ID
		var id_set = {}
		for index in menu.item_count:
			id_set[menu.get_item_id(index)] = null
		
		var id_to_method_map : Dictionary = {}
		var id_to_path_map : Dictionary = {}
		
		var last_id : int = -1
		for data in data_list:
			var menu_path : String = str(data['path'])
			var method : Callable = data.get("method", Callable())
			var accel : int = data.get("accel", KEY_NONE)
			var id : int = data.get("id", -1)
			if id == -1:
				last_id +=1
				while id_set.has(last_id):
					last_id += 1
			# 添加菜单项
			menu.add_item(menu_path.get_file(), id, accel)
			id_to_path_map[id] = menu_path
			if method.is_valid():
				id_to_method_map[id] = method
			id_set[id] = null
			last_id = id
		
		# 点击调用菜单方法
		menu.id_pressed.connect(func(id):
			if id_to_method_map.has(id):
				Callable(id_to_method_map[id]).call()
			self.pressed_menu.emit(id, id_to_path_map[id])
		)
	
	
	func _init_menu_node(root: PopupMenu, list: PackedStringArray):
		_path_to_menu_node[""] = root
		_path_to_menu_node["/"] = root
		
		for i in list:
			i.get_base_dir()
	
	



##  进行添加菜单项
##[br]
##[br][code]menu[/code]  菜单目标
##[br][code]data_list[/code]  添加的菜单。菜单的数据需要是类似以下的结构：
##[codeblock]
##[
##    {"path":"/File/Open", "id": FILE_OPEN, "accel": KEY_MASK_CTRL | KEY_O | "method": func(): pass},
##    {"path":"/File/Save", "id": FILE_SAVE, "accel": KEY_MASK_CTRL | KEY_S | "method": func(): pass},
##    {"path":"/File/Export", "id": FILE_EXPORT, "accel": KEY_MASK_CTRL | KEY_MASK_SHIFT | KEY_E | "method": func(): pass},
##    ...
##]
##[/codeblock]
##[b]注意：[/b]其中必须要有 [code]path[/code] 键的值，否则无法添加
static func add_menu_by_dict(menu: PopupMenu, data_list: Array[Dictionary]) -> _MenuItem:
	return _MenuItem.new(menu, data_list)

