#============================================================
#    Git Remote
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 08:20:23
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Remote


## 冗长信息显示
static func verbose():
	var result = await GitPlugin_Executor.execute(["git remote --verbose"])
	return result["output"]

## 仓库名列表
static func list() -> Array:
	var result = await GitPlugin_Executor.execute(["git remote"])
	return result["output"]

## 添加仓库
static func add(name: String, url: String):
	var command = ["git", "remote", "add", name, url]
	return (
		await GitPlugin_Executor.execute(command)
	)["output"]

## 移除仓库
static func remove(name: String):
	return (
		await GitPlugin_Executor.execute(["git", "remote", "rm", name])
	)["output"]

## 修改仓库名
static func rename(old_remote_name: String, new_remote_name: String):
	return (
		await GitPlugin_Executor.execute(["git", "remote", "rename", old_remote_name, new_remote_name])
	)["output"]


## 显示远程仓库信息
static func show(name: String):
	# TODO 处理信息
	var result = await GitPlugin_Executor.execute(["git", "remote", "show", name])
	return result["output"]


## 检查是否是有效的 URL
static func valid_url(url: String) -> bool:
	var result = await GitPlugin_Executor.execute(["git", "ls-remote", url], 20)
	return result["error"] == OK


