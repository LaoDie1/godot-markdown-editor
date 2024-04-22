#============================================================
#    Process Interrupt Listener
#============================================================
# - author: zhangxuetu
# - datetime: 2023-06-06 16:40:27
# - version: 4.0
#============================================================
## 过程中断监听器
class_name ProcessInterruptListener


static func register(callback: Callable, auto_disconnect: bool = true) -> Callable:
	var count = [0]
	var method = func():
		count = [0]
	
	var p_method = [0]
	p_method[0] = func():
		if count[0] > 1:
			callback.call()
			if auto_disconnect:
				Engine.get_main_loop().physics_frame.disconnect(p_method[0])
	
	Engine.get_main_loop().physics_frame.connect(p_method[0])
	return method

