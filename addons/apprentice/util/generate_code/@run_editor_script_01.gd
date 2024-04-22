# editor_script_00.gd
@tool
extends EditorScript


class AutoSetterGetter:
	
	func _init(script: Script):
		var propertys = ScriptUtil.get_property_name_list(script)
		var setter_getter_data = ScriptUtil.has_getter_or_setter(script, propertys)
		for property in propertys:
			pass
		
	


func _run():
	
	aaa()


func aaa():
	
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
	
	var code = ""
	for property in propertys:
		if not setter_getter_data[property]["setter"]:
			code += generate_setter.call(property) + "\n"
		if not setter_getter_data[property]["getter"]:
			code += generate_getter.call(property) + "\n"
	
	script.source_code += code
	print(script.source_code)
	
	
	
#	var test = Test.new()
	
#	print(test.get_d())
	



