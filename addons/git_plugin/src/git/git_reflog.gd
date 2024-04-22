#============================================================
#    Git Reflog
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 23:03:46
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Reflog


static func execute():
	var result = await GitPlugin_Executor.execute(["git", "reflog"])
	return result["output"]
