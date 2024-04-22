#============================================================
#    Git Show
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-06 16:47:58
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Show


## 此次提交的文件列表
static func files(commit_id: String) -> Array[String]:
	var result = await GitPlugin_Executor.execute(["git show --name-only ", commit_id])
	var output = result["output"]
	
	# 找到文件所在行
	var idx = 0
	for line:String in output:
		if not line.begins_with(" ") and FileAccess.file_exists(line.strip_edges()):
			break
		idx += 1
	
	# 所有文件
	var files : Array[String] = []
	for i in range(idx, output.size()):
		files.append(output[i])
	
	return files




