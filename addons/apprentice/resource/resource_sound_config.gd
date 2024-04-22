#============================================================
#    Sound Config Resource
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-10 21:43:09
# - version: 4.x
#============================================================
# 声音配置
class_name SoundConfig
extends Resource


## 播放的声音流
@export var stream : AudioStream
## 从这个位置开始播放
@export_range(0, 1, 0.001, "or_greater")
var from_position : float = 0.0
## 声音大小控制
@export_range(-80, 24, 0.001, "or_less", "or_greater")
var volume_db : float = 0.0
## 播放的速度快慢
@export_range(0, 10, 0.001, "or_greater")
var pitch_scale : float = 1.0
## 延迟播放的时间
@export var delay_time : float = 0.0
## 播放停止时间，从 0 秒开始到这个时间时停止播放
@export var stop_time : float = 0.0
## 循环播放
@export var loop : bool = false:
	set(v):
		if loop != v:
			loop = v
			if loop:
				_audio_player.finished.connect(_next_play)
				_stop_timer.timeout.connect(_next_play, Object.CONNECT_DEFERRED)
			else:
				_audio_player.finished.disconnect(_next_play)
				_stop_timer.timeout.disconnect(_next_play)
## 最大可以听到这个声音的距离
@export var max_distance : float = 200:
	set(v):
		max_distance = v
		_audio_player.max_distance = max_distance


var _audio_player : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
var _stop_timer : Timer = Timer.new()


func add_to(node: Node) -> void:
	_audio_player.stream = stream
	_audio_player.volume_db = volume_db
	_audio_player.pitch_scale = pitch_scale
	_audio_player.max_distance = max_distance
	
	_stop_timer.timeout.connect(func():
		if is_instance_valid(_audio_player):
			_audio_player.stop()
	)
	_stop_timer.one_shot = true
	_audio_player.add_child(_stop_timer)
	
#	assert(_audio_player.is_inside_tree())
	node.add_child.call_deferred(_audio_player)


func _next_play():
	if is_instance_valid(_audio_player):
		if delay_time > 0:
			await Engine.get_main_loop().create_timer(delay_time).timeout
		assert(stream != null, "没有设置声音")
		if not _audio_player.is_inside_tree():
			await _audio_player.tree_entered
		_audio_player.play(from_position)
		if stop_time > 0:
			_stop_timer.start((stop_time - from_position) / pitch_scale)


func get_audio_player() -> AudioStreamPlayer2D:
	if not is_instance_valid(_audio_player):
		return null
	return _audio_player


func play(from_position : float = -1) -> void:
	if from_position >= 0:
		self.from_position = from_position
	_next_play()


func stop() -> void:
	if is_instance_valid(_audio_player):
		_audio_player.stop()

