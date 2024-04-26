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
	static var font_path    # 字体所在路径
	static var font_size
	static var font_color
	static var accent_color # 强调颜色
	static var text_color   # 文字颜色
	static var line_spacing # 行间距


class Path:
	static var current_dir  
	static var opened_files
