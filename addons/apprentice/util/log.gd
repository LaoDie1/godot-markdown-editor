#============================================================
#    Log
#============================================================
# - author: zhangxuetu
# - datetime: 2023-10-04 00:25:06
# - version: 4.1.1.stable
#============================================================
class_name GLog


static func info(desc: String, data = "", indent: String = ""):
	if indent:
		print(Time.get_datetime_string_from_system(), " ", desc, " ", JSON.stringify(data, indent))
	else:
		print(Time.get_datetime_string_from_system(), " ", desc, " ", data)


static func stringify(desc: String, data):
	info(desc, data, "  ")


static func debug(desc: String, data = "", indent: String = ""):
	info(desc, data, indent)
	print("  | {line}: {function}: {source} ".format( get_stack()[1] ))


static func error(desc: String, data = "", indent: String = ""):
	if indent:
		printerr(Time.get_datetime_string_from_system(), " ", desc, " ", JSON.stringify(data, indent))
	else:
		printerr(Time.get_datetime_string_from_system(), " ", desc, " ", data)
