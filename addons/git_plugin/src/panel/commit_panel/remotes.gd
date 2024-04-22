#============================================================
#    Remotes
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 18:17:00
# - version: 4.2.1.stable
#============================================================
@tool
extends VBoxContainer


const ICON = preload("res://addons/git_plugin/src/icon.tres")


@onready var add_remote_window: ConfirmationDialog = %AddRemoteWindow
@onready var remote_url_tree : Tree = %RemoteUrlTree
@onready var delete_confirmation_dialog = %DeleteConfirmationDialog

@onready var _root : TreeItem = remote_url_tree.create_item()


var _url_regex : RegEx = RegEx.new()
var _urls : Dictionary = {}


#============================================================
#  内置
#============================================================
func _init() -> void:
	_url_regex.compile("(?<url>.*?)\\s+\\(\\w+\\)")


func _ready() -> void:
	remote_url_tree.columns = 2
	remote_url_tree.hide_root = true
	remote_url_tree.hide_folding = true
	remote_url_tree.select_mode = Tree.SELECT_ROW
	remote_url_tree.column_titles_visible = true
	remote_url_tree.set_column_title(0, "Name")
	remote_url_tree.set_column_title(1, "URL")
	
	update()



#============================================================
#  自定义
#============================================================
func add_item(remote_name: String, url: String):
	var re = _url_regex.search(url)
	if re:
		url = re.get_string("url")
	
	if not _urls.has(url):
		_urls[url] = null
		
		var item : TreeItem = remote_url_tree.create_item(_root)
		item.set_text(0, remote_name)
		item.set_text(1, url)
		item.add_button(1, ICON.get_icon("Remove", "EditorIcons"))


func update():
	_urls.clear()
	remote_url_tree.clear()
	_root = remote_url_tree.create_item()
	var result = await GitPlugin_Remote.verbose()
	for item: String in result:
		if item != "":
			var split = item.split("\t")
			var remote_name = split[0]
			var url = split[1]
			add_item(remote_name, url)



#============================================================
#  连接信号
#============================================================
func _on_add_remote_url_button_pressed() -> void:
	add_remote_window.popup_centered()


func _on_remote_url_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if id == 0: # 删除
			delete_confirmation_dialog.set_meta("item", item)
			var url = item.get_text(1)
			delete_confirmation_dialog.dialog_text = "确认要删除这个仓库链接？\n\n  %s  \n  " % url
			delete_confirmation_dialog.popup_centered()


func _on_delete_confirmation_dialog_confirmed():
	var item : TreeItem = delete_confirmation_dialog.get_meta("item")
	var remote_name = item.get_text(0)
	await GitPlugin_Remote.remove(remote_name)
	update()

