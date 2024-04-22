#============================================================
#    File Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 16:10:02
# - version: 4.2.1.stable
#============================================================
@tool
class_name GitPlugin_FileTree
extends Tree


## item_file: 原始的带有其他信息的文件名
## file: 纯文件名，没有其他信息
signal edited_file(item_file: String, file: String)
signal actived_file(item_file: String, file: String)


@export var action_texture : Texture2D
@export var new_file_color : Color = Color8(143, 171, 130)
@export var modified_file_color : Color = Color8(250, 227, 69)
@export var deleted_file_color : Color = Color8(196, 89, 89)
@export var enabled_edit : bool = true
@export var enabled_delete : bool = true
@export var enabled_action : bool = true


var _last_select_item : TreeItem
var _root : TreeItem
var _file_to_item_dict : Dictionary = {}
var _file_to_checked_dict : Dictionary = {}

var enum_edit: int = 1:
	get: return 1 if enabled_edit else 0
var enum_delete : int:
	get: return (enum_edit + 1) if enabled_delete else 0
var enum_action : int:
	get: return (sign(enum_edit) + sign(enum_delete) + 1) if enabled_action else 0


#============================================================
#  内置
#============================================================
func _init() -> void:
	hide_root = true
	hide_folding = true
	
	_root = create_item()
	button_clicked.connect(button_click)
	item_activated.connect(
		func():
			# 双击
			var item = get_selected()
			var item_file = item.get_meta("item_file")
			var file = item.get_meta("file")
			actived_file.emit(item_file, file)
	)
	item_selected.connect(
		func():
			await Engine.get_main_loop().process_frame
			_last_select_item = get_selected()
	)
	item_mouse_selected.connect(
		func(position: Vector2, mouse_button_index: int):
			if mouse_button_index == MOUSE_BUTTON_LEFT:
				if position.x >= 4 and position.x <= 24:
					# 点击复选框
					var item = get_selected()
					var status = not item.is_checked(0)
					set_checked(item, status)
					
					# Shift 多个操作
					if (Input.is_key_pressed(KEY_SHIFT) 
						and _last_select_item
						and _last_select_item != item
					):
						var begin = _last_select_item.get_index()
						var end = item.get_index()
						if end < begin:
							var tmp = end
							end = begin
							begin = tmp
						for i in range(begin, end + 1):
							set_checked(_root.get_child(i), status)
	)



#============================================================
#  自定义
#============================================================
func init_items(items: Array):
	_last_select_item = null
	_file_to_item_dict.clear()
	clear_items()
	add_items(items)


func add_items(items: Array):
	for item_file:String in items:
		add_item(item_file)


func add_item(item_file: String):
	if _file_to_item_dict.has(item_file):
		return
	
	var tag : String = item_file[1] if item_file[1] != " " else item_file[0]
	var type_desc : String = GitPlugin_Status.get_type_description(item_file)
	if tag == GitPlugin_Status.Type.untracked:
		type_desc = "New File"
	
	var file : String = item_file.substr(3)
	if tag == GitPlugin_Status.Type.renamed:
		file = file.split("->")[1].strip_edges(true, false)
	
	# 创建
	var item : TreeItem = _root.create_child()
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	set_checked(item, _file_to_checked_dict.get(item_file, true), item_file)
	
	# 颜色
	match tag:
		GitPlugin_Status.Type.modified:
			if modified_file_color != Color.WHITE:
				item.set_custom_color(0, modified_file_color)
			
		GitPlugin_Status.Type.deleted: 
			if deleted_file_color != Color.WHITE:
				item.set_custom_color(0, deleted_file_color)
			
		GitPlugin_Status.Type.new_file, \
		GitPlugin_Status.Type.untracked, \
		GitPlugin_Status.Type.renamed:
			if new_file_color != Color.WHITE:
				item.set_custom_color(0, new_file_color)
			
		_:
			print(" >>> FileTree: item type = ", type_desc)
	
	# 文件名
	item.set_text(0, file + " (%s)" % type_desc.capitalize())
	item.set_tooltip_text(0, item_file)
	item.set_meta("file", file)
	item.set_meta("item_file", item_file)
	
	# 图标
	item.set_icon_max_width(0, 16)
	item.set_icon(0, GitPlugin_Icons.get_icon(file))
	
	# 按钮
	if enabled_edit and Engine.is_editor_hint():
		item.add_button(0, GitPlugin_Icons.get_icon_by_name("File")) # 编辑
	if enabled_delete:
		item.add_button(0, GitPlugin_Icons.get_icon_by_name("Close")) # 删除
	if enabled_action:
		if action_texture:
			item.add_button(0, action_texture)
	
	_file_to_item_dict[item_file] = item


func clear_items():
	for child in _root.get_children():
		_root.remove_child(child)


func clear_select_items():
	var children = _root.get_children()
	children.reverse()
	for child in children:
		if child.is_checked(0):
			remove_item(child.get_meta("item_file"))


func remove_item(item_file: String):
	if _file_to_item_dict.has(item_file):
		var item : TreeItem = _file_to_item_dict[item_file]
		_root.remove_child(item)
		_file_to_item_dict.erase(item_file)


func set_checked(item: TreeItem, checked: bool, item_file: String = ""):
	if item_file == "":
		item_file = item.get_meta("item_file")
	item.set_checked(0, checked)
	_file_to_checked_dict[item_file] = checked


## 获取选中的文件原始名
func get_selected_item_file() -> PackedStringArray:
	var list = PackedStringArray()
	for item in _root.get_children():
		if item.is_checked(0):
			list.append(item.get_meta("item_file"))
	return list


## 获取选中的文件路径
func get_selected_files() -> PackedStringArray:
	var list = PackedStringArray()
	for item in _root.get_children():
		if item.is_checked(0):
			list.append(item.get_meta("file"))
	return list


## 获取所有文件
func get_files():
	return _file_to_item_dict.keys()


#============================================================
#  连接信号
#============================================================
func button_click(item: TreeItem, column: int, id: int, mouse_button_index: int):
	id += 1
	
	var file : String = item.get_meta("file")
	var item_file : String = item.get_meta("item_file")
	if id == enum_edit:
		edited_file.emit(item_file, file)
	elif id == enum_delete:
		print("删除 ", file)
	elif id == enum_action:
		actived_file.emit(item_file, file)
	else:
		print("点击", id)
	


