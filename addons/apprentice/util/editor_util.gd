#============================================================
#    Editor Tool
#============================================================
# - datetime: 2022-12-23 19:34:16
#============================================================
## 编辑器工具类（请注意，它只能用在编辑器中，游戏运行后将无效）
class_name EditorUtil


##  获取启用的自定义插件节点列表
##[br][code]return[/code]  
static func get_custom_editor_plugin() -> Array[EditorPlugin]:
	var list : Array[EditorPlugin] = []
	for node in EditorInterface \
		.get_base_control() \
		.get_parent() \
		.get_parent() \
		.get_children():
		if node is EditorPlugin and node.get_class() == "EditorPlugin":
			list.append(node)
	return list

## 获取内置编辑器的插件节点列表
static func get_standard_editor_plugin() -> Array[EditorPlugin]:
	var list : Array[EditorPlugin] = []
	for node in EditorInterface \
		.get_base_control() \
		.get_parent() \
		.get_parent() \
		.get_children():
		if node is EditorPlugin and node.get_class() != "EditorPlugin":
			list.append(node)
	return list

## 获取编辑器根节点
static func get_editor_root() -> Viewport:
	return EditorInterface.get_base_control().get_viewport()

static func get_base_control() -> Control:
	return EditorInterface.get_base_control()

##  获取编辑器主题图标
##[br]
##[br][code]name[/code]  图标名称
##[br]
##[br][code]return[/code]  返回这个图标
static func get_editor_theme_icon(name: StringName) -> Texture2D:
	return EditorInterface \
		.get_base_control() \
		.get_theme_icon(name, "EditorIcons")


## 递归获取编辑器所有节点。以 [code]{"类名"：节点对象}[/code] 结构存储
static func get_editor_node_map() -> Dictionary:
	return DataUtil.singleton("EditorUtil_get_editor_node_by_class", 
		func():
			var node_map : Dictionary = {}
			FuncUtil.recursion(
				EditorUtil.get_editor_root(),
				func(node: Node):
					if node_map.has(node.get_class()):
						node_map[node.get_class()].push_back(node)
					else:
						var list : Array[Node] = []
						list.push_back(node)
						node_map[node.get_class()] = list
					return node.get_children()
			)
			return node_map
	)


##  根据类名获取编辑器节点
static func get_editor_node_by_class(_class_name: StringName) -> Array[Node]:
	return get_editor_node_map().get(_class_name, Array([], TYPE_OBJECT, "Node", null))


static func get_editor_first_node_by_class(_class_name: StringName) -> Node:
	var nodes = get_editor_node_by_class(_class_name)
	return nodes.front() \
		if not nodes.is_empty() \
		else null


##  获取选中的节点
##[br]
##[br][code]return[/code]  返回选中的节点列表
static func get_selected_nodes() -> Array[Node]:
	return EditorInterface.get_selection().get_selected_nodes()


## 获取选中的第一个节点
static func get_selected_first_node() -> Node:
	var list = get_selected_nodes()
	if list.is_empty():
		return null
	return list[0]


##  获取这个路径的文件系统目录
##[br]
##[br][code]path[/code]  目录路径
##[br]
##[br][code]return[/code]  返回这个编辑器文件系统目录
static func get_filesystem_path(path: String) -> EditorFileSystemDirectory:
	return EditorInterface.get_resource_filesystem().get_filesystem_path(path)


## 获取当前选中的文件所在目录，如果没有选中，则返回空字符串
static func get_selected_dir():
	var list = EditorInterface.get_selected_paths()
	if len(list) > 0:
		var path = list[0] as String
		if DirAccess.dir_exists_absolute(path):
			return path
		else:
			return path.get_base_dir()
	return ""


## 获取正在编辑的场景根节点
static func get_edited_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


## 设置场景根节点
static func set_edited_scene_root(node: Node) -> void:
	var scene = PackedScene.new()
	scene.pack(node)
	EditorInterface.edit_resource(scene)
	EditorInterface.get_selection().add_node(node)
	EditorInterface.edit_node(node)


##  获取当前编辑器的编辑视图名称（2D、3D、Script、AssetLib），如果没有这几个，则返回空字符串
static func get_current_main_screen_name() -> String:
	var class_to_node_map = DataUtil.singleton("EditorUtil_clas_to_node_map", func():
		return {
			"CanvasItemEditor": null,
			"Node3DEditor": null,
			"ScriptEditor": null,
			"EditorAssetLibrary": null,
			"CPUParticles3DEditor": null,
			"GPUParticles3DEditor": null,
			"MeshInstance3DEditor": null,
			"MeshLibraryEditor": null,
			"MultiMeshEditor": null,
			"Skeleton2DEditor": null,
			"Sprite2DEditor": null,
			"NavigationMeshEditor": null,
		}
	)
	
	if class_to_node_map.ScriptEditor == null:
		# 扫描子节点
		var main_screen = EditorInterface.get_editor_main_screen()
		for child in main_screen.get_children():
			var class_ = child.get_class()
			if class_to_node_map.has(class_):
				class_to_node_map[class_] = child
		class_to_node_map.ScriptEditor = get_script_editor()
	
	# 2D
	if class_to_node_map.CanvasItemEditor and class_to_node_map.CanvasItemEditor.visible:
		return "2D"
	# 3D
	if class_to_node_map.Node3DEditor and class_to_node_map.Node3DEditor.visible:
		return "3D"
	# Script
	if class_to_node_map.ScriptEditor and class_to_node_map.ScriptEditor.visible:
		return "Script"
	# AssetLib
	if class_to_node_map.EditorAssetLibrary and class_to_node_map.EditorAssetLibrary.visible:
		return "AssetLib"
	
	for name in class_to_node_map:
		if (class_to_node_map[name] 
			and "visible" in class_to_node_map[name]
			and class_to_node_map[name].visible
		):
			pass
	
	return ""


##  获取插件名（这个插件需要是插件可开启或关闭的插件对象，而非自定义的随处放置的插件对象）
##[br]
##[br][code]plugin[/code]  插件对象
##[br]
##[br][code]return[/code]  返回这个插件的插件名
static func get_plugin_name(plugin: EditorPlugin) -> StringName:
	return plugin.get_script().resource_path.get_base_dir().get_file()


##  重新加载插件
##[br]
##[br][code]plugin[/code]  
static func reload_plugin(plugin: EditorPlugin) -> void:
	if plugin != null:
		var plugin_name = get_plugin_name(plugin)
		var editor_interface = EditorInterface
		editor_interface.set_plugin_enabled(plugin_name, false)
		await Engine.get_main_loop().create_timer(0.1).timeout
		editor_interface.set_plugin_enabled(plugin_name, true)
		print("已重新加载 ", plugin_name, " 插件")
	else:
		printerr("<plugin 参数为值 null>")


##  文件系统定位到这个路径
##[br]
##[br][code]path[/code]  要定位的路径
static func navigate_to_path(path: String) -> void:
	EditorInterface.get_file_system_dock().navigate_to_path(path)


## 获取创建场景根节点的按钮
static func get_create_root_node_buttons() -> Dictionary:
	var scene_tree_dock = get_editor_first_node_by_class("SceneTreeDock")
	var create_root_scene_button_container = scene_tree_dock.get_child(2) \
		.get_child(1) \
		.get_child(0) \
		.get_child(0)
	
	return {
		"2D Scene": create_root_scene_button_container.get_child(0),
		"3D Scene": create_root_scene_button_container.get_child(1),
		"User Interface": create_root_scene_button_container.get_child(2),
		"Other Node": create_root_scene_button_container.get_parent().get_child(2),
	}


##  获取创建新节点弹窗的节点
static func get_create_new_node_dialog() -> Window:
	var scene_tree_dock = get_editor_first_node_by_class("SceneTreeDock")
	return scene_tree_dock.get_child(4)


##  获取文件系统的鼠标菜单
static func get_file_system_dock_menu() -> PopupMenu:
	var file_dock = EditorInterface.get_file_system_dock()
	return file_dock.get_child(2) as PopupMenu


##  获取2D编辑器画布节点
static func get_2d_editor() -> Control:
	return get_editor_first_node_by_class("CanvasItemEditor")

##  获取2D编辑器画布节点
static func get_3d_editor() -> Control:
	return get_editor_first_node_by_class("Node3DEditor")

## 获取属性检查器
static func get_inspector_dock() -> EditorInspector:
	return EditorInterface.get_inspector()


##  添加2D编辑器工具按钮
##[br]
##[br][code]button[/code]  
##[br][code]add_separator[/code]  
static func add_2d_editor_tool_button(button: BaseButton):
	var hbox := DataUtil.singleton("EditorUtil_add_2d_editor_tool_button_2d_hbox", func():
		var hbox = HBoxContainer.new()
		var canvas = get_2d_editor() #as CanvasItemEditor
		var tool_button_container := canvas.get_child(0) as Node
		tool_button_container.add_child.call_deferred(hbox)
		return hbox
	) as Control
	
	hbox.add_child(button)


##  获取当前脚本编辑器
static func get_script_editor() -> ScriptEditor:
	return EditorInterface.get_script_editor()

## 获取前编辑的脚本
static func get_current_script() -> Script:
	return get_script_editor().get_current_script()

static func get_current_script_code_editor() -> CodeEdit:# -> CodeTextEditor:
	var code_edit =  get_script_editor_code_editor( get_script_editor() )
	return code_edit

static func get_script_editor_code_editor(script_editor: ScriptEditor) -> CodeEdit:
	if script_editor:
		var node = script_editor.get_current_editor()
		return node.get_child(0).get_child(0).get_child(0)
	return null


##  获取当前脚本编辑器行列位置
##[br]x 为列，y 为行
##[br][code]return[/code]  返回行列位置，如果没有代码编辑，则返回 [code]Vector2i(-1, -1)[/code]
static func get_current_script_editor_column_line() -> Vector2i:
	var code_edit = EditorUtil.get_current_script_code_editor()
	if code_edit:
		return Vector2i( code_edit.get_caret_column(), code_edit.get_caret_line())
	return Vector2i(-1, -1)

static func get_current_script_editor_line() -> int:
	var code_edit = EditorUtil.get_current_script_code_editor()
	if code_edit:
		return code_edit.get_caret_line()
	return -1

static func get_current_script_editor_column() -> int:
	var code_edit = EditorUtil.get_current_script_code_editor()
	if code_edit:
		return code_edit.get_caret_column()
	return -1


static func get_current_script_editor_line_text() -> String:
	var line = EditorUtil.get_current_script_editor_line()
	if line > -1:
		var code_edit = get_current_script_code_editor()
		return code_edit.get_line(line)
	return ""


class _PreviewTexture:
	
	static func _preview(path: String, preview: Texture2D, thumbnail_preview: Texture2D, callback: Callable):
		callback.call(preview, thumbnail_preview)


##  获取资源预览图片
##[br]
##[br][code]res_path[/code]  资源路径
##[br][code]callback[/code]  图片回调方法。这个方法需要有 preview （[Texture2D] 类型），thumbnail_preview （[Texture2D] 类型）两个参数
static func get_res_preview_texture(res_path: String, callback: Callable) -> void:
	var previewer = EditorInterface.get_resource_previewer() as EditorResourcePreview
	previewer.queue_resource_preview(res_path, _PreviewTexture, "_preview", callback)


## 获取编辑器属性
static func get_editor_setting_property(property: String):
	return EditorInterface.get_editor_settings().get(property)

## 设置编辑器属性
static func set_editor_setting_property(property: String, value) -> void:
	EditorInterface.get_editor_settings().set(property, value)


## 设置编辑器当前的显示的场景。比如默认的：2D, 3D, Script, AssetLib
static func set_main_screen_editor(name: StringName) -> void:
	EditorInterface.set_main_screen_editor(name)


##  获取场景包的根节点的属性
##[br]
##[br][code]scene[/code]  场景资源文件
##[br][code]property[/code]  属性。如果没有设置这个值，则返回 [code]null[/code]
static func get_packed_scene_root_property_value(scene: PackedScene, property: String):
	var state = scene.get_state() as SceneState
	for i in state.get_node_property_count(0):
		var prop = state.get_node_property_name(0, i)
		if prop == "editor_description":
			return state.get_node_property_value(0, i)
	return null


##  获取场景包数据
##[br]
##[br][code]scene[/code]  场景包
##[br][code]return[/code]  返回这个场景的数据
static func get_scene_data(scene: PackedScene) -> Dictionary:
	var state : SceneState = scene.get_state()
	var path_to_node_data : Dictionary = {}
	var node_path 
	for idx in state.get_node_count():
		var data : Dictionary = {}
		
		# 节点名称
		data["name"] = state.get_node_name(idx)
		# 节点类型
		data["class"] = state.get_node_type(idx)
		# 所在组
		data['groups'] = state.get_node_groups(idx)
		
		# 覆盖的属性
		var prop : String
		var value
		for prop_idx in state.get_node_property_count(idx):
			prop = state.get_node_property_name(idx, prop_idx)
			value = state.get_node_property_value(idx, prop_idx)
			data[prop] = value
		
		node_path = str(state.get_node_path(idx)).right(-2)
		path_to_node_data[node_path] = data
	
	return path_to_node_data


## 获取当前编辑器的地区语言
static func get_editor_language() -> String:
	return EditorInterface \
		.get_editor_settings() \
		.get('interface/editor/editor_language')


##  添加编辑器菜单
##[br]
##[br][code]popup[/code]  菜单节点
##[br][code]menu_name[/code]  菜单名称，如果没有，则默认按照节点名称
static func add_editor_menu(popup: PopupMenu, menu_name: String = "") -> void:
	var panel = EditorInterface.get_base_control()
	var base_container = panel.get_child(0)
	var editor_tile_bar = base_container.get_child(0)
	var editor_menu_bar = editor_tile_bar.get_child(0) as MenuBar
	if menu_name != "":
		popup.name = menu_name
	editor_menu_bar.add_child(popup)


##  获取编辑器菜单
##[br]
##[br][code]idx[/code]  菜单索引
##[br][code]return[/code]  返回这个节点
static func get_editor_menu(idx: int) -> PopupMenu:
	var panel = EditorInterface.get_base_control()
	var base_container = panel.get_child(0)
	var editor_tile_bar = base_container.get_child(0)
	var editor_menu_bar = editor_tile_bar.get_child(0) as MenuBar
	
	var i : int = -1
	for node in editor_menu_bar.get_children():
		if node is PopupMenu:
			i += 1
			if i == idx:
				return node
	return null


##  获取主屏幕切换按钮
##[br]
##[br][code]idx[/code]  
##[br][code]return[/code]  
static func get_main_screen_button(idx: int) -> Button:
	var panel = EditorInterface.get_base_control()
	var base_container = panel.get_child(0)
#	var editor_tile_bar = get_editor_node_by_class("EditorTitleBar").front()
	var editor_tile_bar = base_container.get_child(0)
	var screen_button_container = editor_tile_bar.get_child(2)
	
	var i : int = -1
	for node in screen_button_container.get_children():
		if node is Button and node.visible:
			i += 1
			if i == idx:
				return node
	return null


static func get_scene_tree_dock() -> Control:
	return get_editor_first_node_by_class("SceneTreeDock")


## 获取文件系统的 dock
static func get_file_system_dock() -> FileSystemDock:
	return EditorInterface.get_file_system_dock()


## 是否在编辑器当中。详细请参阅：https://docs.godotengine.org/en/4.0/tutorials/export/feature_tags.html
static func is_debug() -> bool:
	return OS.has_feature("debug")


## 当前是 editor 运行游戏
static func is_editor() -> bool:
	return OS.has_feature("editor")


## 扫描文件
static func scan_files():
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_resource_filesystem().scan_sources()
