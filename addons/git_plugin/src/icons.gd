#============================================================
#    Icons
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-06 18:10:18
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Icons


const ICON = preload("res://addons/git_plugin/src/icon.tres")


static func get_icon(file: String) -> Texture2D:
	match file.get_extension():
		"gd": return ICON.get_icon("Script", "EditorIcons")
		"tscn", "scn": return ICON.get_icon("PackedScene", "EditorIcons")
		"tres", "res": return ICON.get_icon("ResourcePreloader", "EditorIcons")
		_:
			if file.get_file() == "":
				return ICON.get_icon("Folder", "EditorIcons")
			else:
				return ICON.get_icon("File", "EditorIcons")


static func get_icon_by_name(name: String):
	return ICON.get_icon(name, "EditorIcons")


