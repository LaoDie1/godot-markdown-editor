#============================================================
#    Git Restore
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-04 13:55:15
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Restore


static func execute(file_or_files):
	if file_or_files.is_empty():
		return
	
	var files : PackedStringArray
	if file_or_files is Array or file_or_files is PackedStringArray:
		files = PackedStringArray(file_or_files)
	elif file_or_files is String:
		files = PackedStringArray([file_or_files])
	else:
		assert(false, "错误的参数类型")
	
	# 分批次
	var batch_count: int = 30
	var batch_total : int = int(files.size() / batch_count) 
	batch_total += sign(files.size() % batch_count)
	
	# 添加
	var output = []
	for i in batch_total:
		var items = Array(files.slice(i * batch_count, (i+1) * batch_count))
		var command = ["git restore --staged "]
		command.append_array(items)
		var result = await GitPlugin_Executor.execute(command)
		output.append(result)
	
	return output
