#============================================================
#    Image Request
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 18:38:55
# - version: 4.3.0.dev5
#============================================================
extends HTTPRequest


var queue : Array[Dictionary] = []
var current_data : Dictionary = {}


#============================================================
#  自定义
#============================================================
func _execute_next():
	current_data.clear()
	if queue.is_empty():
		return
	current_data = queue.pop_front()
	
	var err = request(current_data["url"], [], HTTPClient.METHOD_GET)
	print("--- 请求图片：", current_data["url"])
	if err != OK:
		printerr("请求错误: ", err, " ", error_string(err))


func queue_request(url: String, callback: Callable):
	var data = {}
	data["url"] = url
	data["callback"] = callback
	queue.push_back(data)
	
	if get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		_execute_next()


#============================================================
#  连接信号
#============================================================
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var image = FileUtil.load_image_by_buff(body)
	var callback : Callable = current_data["callback"]
	callback.call( {
		"result": result,
		"response_code": response_code,
		"headers": headers,
		"body": body,
		"image": image,
	} )
	_execute_next.call_deferred()
