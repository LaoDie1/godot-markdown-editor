#============================================================
#    Remote Url Tree
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 16:46:30
# - version: 4.2.1.stable
#============================================================
@tool
extends Tree


var _root : TreeItem = create_item()


#============================================================
#  内置
#============================================================
func _init() -> void:
	columns = 2
	hide_root = true
	hide_folding = true
	select_mode = Tree.SELECT_ROW
	column_titles_visible = true
	set_column_title(0, "Name")
	set_column_title(1, "URL")
	button_clicked.connect(
		func(item: TreeItem, column: int, id: int, mouse_button_index: int):
			if mouse_button_index == MOUSE_BUTTON_LEFT:
				# 删除
				if id == 0:
					print("删除")
					_root.remove_child(item)
	)


#============================================================
#  自定义
#============================================================
func add_item(remote_name: String, url: String):
	var item = create_item(_root)
	item.set_text(0, remote_name)
	item.set_text(1, url)
	
	item.add_button(1, GitPlugin_Icons.get_icon_by_name("Remove"))


func update():
	var result = await GitPlugin_Remote.verbose()
	for item: String in result:
		if item != "":
			var split = item.split("\t")
			var remote_name = split[0]
			var url = split[1]
			add_item(remote_name, url)
