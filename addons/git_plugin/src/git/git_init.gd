#============================================================
#    Git Init
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 22:46:39
# - version: 4.2.1.stable
#============================================================
## 初始化 git
class_name GitPlugin_Init


## git初始化并设置默认分支名称。[kbd]branch_name[/kbd] 参数值一般为 master 或 main
static func execute(branch_name: String):
	var init_result = await GitPlugin_Executor.execute(["git", "init"])
	var branch_result = await GitPlugin_Executor.execute(["git", "branch", "-M", branch_name])
	print_debug(
		"init: ", init_result, "\n\n",
		"branch: ", branch_result,
	)

