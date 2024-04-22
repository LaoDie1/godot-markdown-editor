#============================================================
#    Radio Station
#============================================================
# - author: zhangxuetu
# - datetime: 2023-10-05 16:09:04
# - version: 4.2.0.dev6
#============================================================
## 广播站
##
##主要用于设置带有优先级的信号的角色
##每个收听频道的回调都要有个类型为 [Dictionary] 类型的参数接收频道广播的数据。
##类似信号，但是可以设置优先级
class_name RadioStation
extends Node


static var _id_to_signal_script : Dictionary = {}

var _channel_to_queue : Dictionary = {}
var _id_to_signal_object : Dictionary = {}


func _get_channel_data(channel) -> PriorityQueue:
	var queue = _channel_to_queue.get(channel)
	if queue:
		return queue
	else:
		queue = PriorityQueue.new()
		_channel_to_queue[channel] = queue
		return queue

## 是否有这个频道
func has_channel(channel) -> bool:
	return _channel_to_queue.has(channel)

## 收听频道
func listen(channel, callback: Callable, priority: int = 0):
	_get_channel_data(channel).append(priority, callback)

## 取消收听频道
func cancel_listen(channel, callback: Callable):
	_get_channel_data(channel).remove(callback)

## 手动对频道发送数据
func send(channel, data: Dictionary):
	for item in _get_channel_data(channel).get_all_item():
		item.call(data)

## 添加频道。信号发出时自动向频道发送数据
func add_channel(channel, _signal: Signal):
	var object = _signal.get_object()
	var signal_name = _signal.get_name()
	var id = [channel, object.get_instance_id(), signal_name].hash()
	if _id_to_signal_object.has(id):
		printerr("[ RadioStation ] 已经添加过这个频道. ", {
			"channel": channel,
			"signal": signal_name,
		})
		return
	
	var signal_script = get_signal_script(object.get_class(), object.get_script(), signal_name)
	var signal_object = signal_script.new()
	signal_object.radio_station = self
	signal_object.channel = channel
	_id_to_signal_object[id] = signal_object
	_signal.connect(signal_object.execute)


## 删除频道
func remove_channel(channel):
	_channel_to_queue.erase(channel)


## 获取这个信号的脚本
static func get_signal_script(_class: String, script: Script, signal_name: StringName):
	var id = [_class, signal_name]
	var signal_script := _id_to_signal_script.get(id) as GDScript
	if signal_script:
		return signal_script
	
	# 自动生成对应类的信号的脚本
	var signal_list : Array = []
	if script:
		signal_list = script.get_script_signal_list()
	signal_list.append_array(ClassDB.class_get_signal_list(_class, false))
	for signal_data in signal_list:
		if signal_data["name"] == signal_name:
			signal_script = GDScript.new()
			var arg_names : Array = signal_data["args"].map(
				func(d):
					return d["name"]
			)
			var params = arg_names.map(
				func(arg):
					return "\t\t" + arg + " = " + arg
			)
			signal_script.source_code = """
extend RefCounted

var radio_station
var channel

func execute({arg_array}):
	radio_station.send(channel, {
{params}
	})

""".format({
	"arg_array": ", ".join(arg_names),
	"params": ",\n".join(params),
})
			break
	signal_script.reload()
	_id_to_signal_script[id] = signal_script
	return signal_script
