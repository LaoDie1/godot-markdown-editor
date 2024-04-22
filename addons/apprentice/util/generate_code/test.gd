#============================================================
#    Test
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-08 12:14:29
# - version: 4.0
#============================================================
extends Node2D



func _ready():
	
	var script = (Test) as Script
	var propertys = ScriptUtil.get_property_name_list(script)
	var setter_getter_data = ScriptUtil.has_getter_or_setter(script, propertys)
	
	var generate_setter = func(property):
		return "func set_{property}(value):\n\t{property} = value\n".format({
			"property": property,
		})
	var generate_getter = func(property):
		return "func get_{property}():\n\treturn {property}\n".format({
			"property": property,
		})
	
	var code = "\n"
	for property in propertys:
		if not setter_getter_data[property]["setter"]:
			code += generate_setter.call(property) + "\n"
		if not setter_getter_data[property]["getter"]:
			code += generate_getter.call(property) + "\n"
	
	script.source_code += code
	script.reload()
	
	var test = Test.new()
	test.set_a(55)
	print(test.get_a())
	
