#============================================================
#    Git Branch
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-03 09:38:34
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Branch


## 当前分支
static func show_current() -> String:
	var result = await GitPlugin_Executor.execute(["git branch --show-current"])
	var output = result["output"]
	if output.size() > 0:
		return output[0]
	else:
		return ""

## 本地分支列表
static func list() -> Array:
	var result = await GitPlugin_Executor.execute(["git branch --list"])
	return result["output"]

## 列出远程跟踪和本地分支
static func all():
	var result = await GitPlugin_Executor.execute(["git branch --all"])
	return result["output"]

## 远程分支
static func remotes():
	var result = await GitPlugin_Executor.execute(["git branch --remotes"])
	return result["output"]




