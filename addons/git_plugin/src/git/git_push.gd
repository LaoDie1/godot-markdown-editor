#============================================================
#    Git Push
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 23:02:48
# - version: 4.2.1.stable
#============================================================
## 推送
class_name GitPlugin_Push


## 设置推流
static func set_upstream(remote_name: String, branch_name: String):
	var command = ["git push --set-upstream %s %s " % [remote_name, branch_name] ]
	var result = await GitPlugin_Executor.execute(command, 20)
	return result["output"]


## 执行推送
static func execute(remote_name: String, branch_name: String):
	var command = ["git", "push", "-u", remote_name, branch_name ]
	var result = await GitPlugin_Executor.execute(command)
	return result["output"]




