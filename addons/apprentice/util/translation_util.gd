#============================================================
#    Translation Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-22 13:05:57
# - version: 4.0
#============================================================
## 翻译工具
##
##直接读取 csv 文件读取翻译的文件。
class_name TranslationUtil



## 翻译文件数据对象
class TransObj:
	## 每行翻译文字
	var lines : Array[PackedStringArray] = []
	## 地区名称对应的列索引
	var locale_str_to_index : Dictionary = {}
	## 每个 key 对应的行
	var key_to_line_index : Dictionary = {}
	
	## 默认翻译地区
	var default_locale : String = "en"
	
	func _init(path: String):
		lines = FileUtil.read_as_csv(path)
		if lines.is_empty():
			return
		
		# 头部行，每个项对应每列的地区的翻译
		var locales = lines[0]
		var locale : String
		for idx in locales.size():
			locale = locales[idx]
			locale_str_to_index[locale] = idx
		
		# 每个 key 对应的行索引
		var line : PackedStringArray
		var key : String
		for idx in lines.size():
			line = lines[idx]
			key = line[0]
			key_to_line_index[key] = idx
	
	## 设置默认获取的地区的翻译
	func set_default_locale(locale: String) -> void:
		# 断言是否有这个地区的翻译
		if not locale_str_to_index.has(locale):
			if locale.find("_") > -1:
				locale = locale.left(locale.find("_"))
				assert(locale_str_to_index.has(locale), "There is no translation for this region! locale = " + locale)
		
		default_locale = locale
	
	## 获取翻译
	##[br]
	##[br][code]key[/code]  翻译文字
	##[br][code]locale[/code]  所在国家地区
	func get_message(key: String, locale: String = "") -> String:
		if locale == "":
			locale = default_locale
		var line_index = key_to_line_index.get(key, -1)
		if line_index > -1:
			var locale_index : int = locale_str_to_index.get(locale, -1)
			if locale_index > -1:
				return lines[line_index][locale_index]
		return ""
	


##  加载翻译文件。这个翻译文件需要是 csv 文件，而不是 translation 文件
##[br]
##[br][code]file_path[/code]  文件路径
##[br][code]cache[/code]  是否缓存读取的文件，如果为 [code]true[/code] 则后续读取这个文件则会返回第一次读取的翻译对象
##[br][code]return[/code]  返回翻译文件对象
static func load_traslation_file(file_path: String, cache: bool = false) -> TransObj:
	if cache:
		var data : Dictionary
		const KEY = "TranslationUtil_cache_translation_file"
		if Engine.has_meta(KEY):
			data = Engine.get_meta(KEY)
		else:
			data = {}
			Engine.set_meta(KEY, data)
		
		if data.has(file_path):
			return data[file_path]
		else:
			var trans_obj : TransObj = TransObj.new(file_path)
			data[file_path] = trans_obj
			return trans_obj
	
	return TransObj.new(file_path)


