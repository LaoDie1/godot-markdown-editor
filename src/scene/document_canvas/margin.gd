#============================================================
#    Margin
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 03:55:57
# - version: 4.2.2.stable
#============================================================
class_name Margin
extends RefCounted


var left : float = 0
var right : float = 0
var top : float = 0
var bottom : float = 0


func _init(params: Dictionary = {}):
	for p in params:
		if p in self:
			self[p] = params[p]
