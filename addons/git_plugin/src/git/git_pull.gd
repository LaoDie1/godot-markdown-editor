#============================================================
#    Git Pull
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 23:03:14
# - version: 4.2.1.stable
#============================================================
## 拉取合并，更新到新代码
class_name GitPlugin_Pull


static func execute(remote_name: String, branch_name: String):
	var result
	if remote_name != "" and branch_name != null:
		result = await GitPlugin_Executor.execute(["git", "pull", remote_name, branch_name, "--allow-unrelated-histories"], 20)
	else:
		result = await GitPlugin_Executor.execute(["git", "pull"], 20)
	return result["output"]
