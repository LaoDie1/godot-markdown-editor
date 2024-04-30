#============================================================
#    Config Key
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 01:24:12
# - version: 4.2.2.stable
#============================================================
## 配置数据中的 key。静态变量值已在 Config 类中初始化
class_name ConfigKey


class Display:
	static var font: BindPropertyItem    # 字体所在路径
	static var font_path: BindPropertyItem    # 字体所在路径
	static var font_size: BindPropertyItem
	static var font_color: BindPropertyItem
	static var accent_color: BindPropertyItem # 强调颜色
	static var text_color: BindPropertyItem   # 文字颜色
	static var line_spacing: BindPropertyItem # 行间距


class Path:
	static var current_dir: BindPropertyItem
	static var opened_files: BindPropertyItem


class Dialog:
	static var open_dir: BindPropertyItem
	static var save_dir: BindPropertyItem
	static var scan_dir: BindPropertyItem
	

