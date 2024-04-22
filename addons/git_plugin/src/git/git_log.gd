#============================================================
#    Git Log
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 23:00:46
# - version: 4.2.1.stable
#============================================================
## 查看提交记录日志
class_name GitPlugin_Log


## 获取最近几条日志的信息。item_number 如果为 0 则返回所有日志信息
static func execute(item_number: int = 0):
	# CAUTION: 下面命令中的 \t 不能去掉，否则一些中文乱码会导致换行符丢失，需要加个字符分隔一下
	var result
	if item_number > 0:
		result = await GitPlugin_Executor.execute([
			'git log --pretty="%H;;;%cd;;;%s\t" --date=iso ',
			"-" + str(item_number)
		])
	else:
		result = await GitPlugin_Executor.execute(['git log --pretty="%H;;;%cd;;;%s\t" --date=iso'])
	return _handle_result(result["output"])


# 处理结果
static func _handle_result(output):
	# 对每次提交进行分组
	var list = []
	for line:String in output:
		if line != "":
			var items = line.split(";;;")
			list.append({
				"id": items[0],
				"date": items[1].substr(0, 19),
				"desc": items[2].strip_edges(),
			})
	return list

