#============================================================
#    Precondition
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-23 01:04:35
# - version: 4.0
#============================================================
## 执行条件
class_name Precondition


var _conditions : Array[Callable] = []


#============================================================
#  内置
#============================================================
func add(condition: Callable) -> Callable:
	_conditions.append(condition)
	return condition


func remove(condition: Callable):
	_conditions.erase(condition)


func check(params: Array = []) -> bool:
	for condition in _conditions:
		if not condition.callv(params):
			return false
	return true

