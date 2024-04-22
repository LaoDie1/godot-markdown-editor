#============================================================
#    Git Status
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 22:42:34
# - version: 4.2.1.stable
#============================================================
## 文件状态 https://blog.csdn.net/weixin_44567318/article/details/119701438
##[br][code]git status --short[/code] 命令执行后的每行的项的状态
class_name GitPlugin_Status


const Type = {
	"unchanged": " ", #' ' （空格）表示文件未发生更改
	"modified": "M",  # M  表示文件发生改动。
	"new_file": "A",  # A  表示新增文件。
	"deleted": "D",   # D  表示删除文件。
	"renamed": "R",   # R  表示重命名。
	"copy": "C",      # C  表示复制。
	"unmerged": "U",  # U  表示更新但未合并。
	"untracked": "?", # ?  表示未跟踪文件
	"ignore": "!",    # !  表示忽略文件。
}
const TypeName = {
	" ": "unchanged",
	"M": "modified",
	"A": "new_file",
	"D": "deleted",
	"R": "renamed",
	"C": "copy",
	"U": "unmerged",
	"?": "untracked",
	"!": "ignore",
}
static var type_name : Dictionary = {}


## 获取这个类型的描述
static func get_type_description(item: String) -> String:
	var type = item[1]
	if type == " ":
		type = item[0]
	return TypeName[type]

## 文件是否未跟踪
static func is_untracked_file(item: String):
	# 第一列字符表示版本库与暂存区之间的比较状态
	# 第二列字符表示暂存区与工作区之间的比较状态
	return item[1] == Type.untracked

## 是否是已提交文件
static func is_committed_file(item: String):
	return (item[0] != Type.unchanged 
		and item[0] != Type.untracked 
		and item[0] != Type.ignore
		and item[1] == " "
	)

## 获取文件列表
static func execute():
	var command = ["git status -su" ]
	var result = await GitPlugin_Executor.execute(command)
	var untracked = []
	var changed = []
	var committed = []
	for item in result["output"]:
		if is_untracked_file(item):
			untracked.append(item)
		elif is_committed_file(item):
			committed.append(item)
		else:
			changed.append(item)
	return {
		"untracked": untracked, # 未追踪
		"changed":   changed,   # 修改未提交
		"committed": committed, # 确定提交
	}

