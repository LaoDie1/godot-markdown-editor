#============================================================
#    Git-ls-files
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 19:47:53
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_ls_files


## 列出所有跟踪的文件
static func all():
	return await GitPlugin_Executor.execute(["git ls-files"])

