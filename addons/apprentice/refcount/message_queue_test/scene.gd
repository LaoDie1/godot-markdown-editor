#============================================================
#    Scene
#============================================================
# - datetime: 2023-02-08 15:53:28
#============================================================
extends Control


var producer := MessageQueue.create_producer("chat")
var monitor := MessageQueue.create_monitor("chat", 
	func(message):
		content.text += "\n" + message
,  MessageQueue.DEFAULT_CHANNEL, MessageQueue.Process.TIMER, 1
)


@onready 
var message_box = $message_box
@onready 
var content = $content


#============================================================
#  连接信号
#============================================================
func _on_send_pressed():
	if message_box.text != "":
		producer.send_message(message_box.text)
		message_box.text = ""
	else:
		print("没有输入消息内容")


