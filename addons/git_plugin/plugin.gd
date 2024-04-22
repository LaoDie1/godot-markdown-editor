#============================================================
#    Plugin
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-04 20:57:40
# - version: 4.2.1.stable
#============================================================
@tool
extends EditorPlugin


const MAIN = preload("res://addons/git_plugin/src/main.tscn")

var plugin_control : GitPlugin_Main


func _enter_tree() -> void:
	plugin_control = MAIN.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, plugin_control)
	
	# 文件新增/删除后
	EditorInterface.get_resource_filesystem() \
		.filesystem_changed.connect(update_commit_files.bind(null), Object.CONNECT_DEFERRED)
	# 保存资源后
	resource_saved.connect(update_commit_files, Object.CONNECT_DEFERRED)


func _exit_tree() -> void:
	remove_control_from_docks(plugin_control)


var _updating : bool = false
func update_commit_files(resource):
	if _updating:
		return
	
	_updating = true
	await Engine.get_main_loop().process_frame
	plugin_control.commit_panel.commit.update()
	_updating = false

