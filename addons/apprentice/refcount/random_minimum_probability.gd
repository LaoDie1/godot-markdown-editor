 #============================================================
#    Random Minimum Probability
#============================================================
# - datetime: 2023-03-04 01:21:34
# - version: 4.x
#============================================================
## 保底概率随机，在概率的次数内一定会触发对应概率
##
## [code]1.0 / probability[/code] 次数概率内一定会触发一次
class_name RandomMinimumProbability


var _max_num : int = 0
var _num : int = 0
var _prob : float = 0.0 : set = set_probability


##[br][code]probability[/code]  概率值
func _init(probability: float = 0.0):
	set_probability(probability)


func set_probability(value: float):
	_prob = value
	_max_num = ceilf(1.0 / _prob) if _prob != 0 else 0
	_num = _max_num


func update_probability(value: float):
	set_probability(value)


## 检查是否触发概率
func check() -> bool:
	if _prob == 0:
		return false
	
	var success : bool = false
	
	# 这些次数的随机值，是否都比设置的概率要小
	var tmp : int = 0
	for i in _max_num:
		if randf() < _prob:
			tmp += 1
	success = (tmp >= _num)
	
	if not success:
		_num -= 1
	else:
		_num = _max_num
	
	return success


