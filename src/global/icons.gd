#============================================================
#    Icons
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 15:40:37
# - version: 4.3.0.dev5
#============================================================
class_name Icons


const ICONS = preload("icons.tres")


static func get_icon(name: String) -> Texture2D:
	return ICONS.get_icon(name, "EditorIcons")
