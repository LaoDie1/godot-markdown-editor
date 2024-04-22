#============================================================
#    Git Commit
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-02 22:53:41
# - version: 4.2.1.stable
#============================================================
class_name GitPlugin_Commit


static func execute(desc: String):
	var result = await GitPlugin_Executor.execute([ "git commit -m \"%s\"" % desc ])
	return result["output"]
