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
	if err != OK:
		printerr("请求错误: ", error_string(err))


func queue_request(url: String, callback: Callable):
	var data = {}
	data["url"] = url
	data["callback"] = callback
	queue.push_back(data)
	_execute_next()


#============================================================
#  连接信号
#============================================================
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var file_type = FileUtil.get_image_type_by_bytes(body)
	var image = Image.new()
	match file_type:
		FileUtil.ImageType.PNG:
			image.load_png_from_buffer(body)
		FileUtil.ImageType.WEBP:
			image.load_webp_from_buffer(body)
		FileUtil.ImageType.JPG:
			image.load_jpg_from_buffer(body)
		FileUtil.ImageType.BMP:
			image.load_bmp_from_buffer(body)
		_:
			printerr("其他图片类型")
	
	var callback : Callable = current_data["callback"]
	callback.call( {
		"result": result,
		"response_code": response_code,
		"headers": headers,
		"body": body,
		"image": image,
	} )
	
	_execute_next()
