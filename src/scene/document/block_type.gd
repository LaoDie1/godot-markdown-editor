#============================================================
#    Block Type
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-26 03:33:57
# - version: 4.3.0.dev5
#============================================================
## 每个行的每个块
class_name BlockType


enum Token {
	TEXT,     ## 文本
	IMAGE,    ## 图片
	LINK,     ## 链接
	
	ITALIC,   ## *
	BOLD,     ## **
	ITALIC_BOLD, ## ***
	CODE,     ## 代码  `
	DELETE,   ## 删除线 ~~
}

const KeywordBegin = {
	KEY_EXCLAM: "!",
	KEY_BRACKETLEFT: "[",
	KEY_LESS: "<",
}

const KeywordEnd = {
	KEY_BRACKETRIGHT: "]",
	KEY_GREATER: ">",
	KEY_PARENRIGHT: ")",
}


## 处理文本块（代码块则不需要调用）
static func handle_block(text: String) -> Array[Block]:
	var bytes: PackedByteArray = text.to_ascii_buffer()
	var point: int = 0
	var blocks : Array[Block] = []
	while point < bytes.size():
		# 找到下一个块的开始位置
		var begin = BlockType.find_block_begin(bytes, point)
		if begin["point"] - point > 0:
			
			# 开始位置之前的内容为普通字符串
			var block = Block.new(bytes, point)
			block.begin = point
			block.end = begin["point"]
			block.token = BlockType.Token.TEXT
			block.text = text.substr(block.begin, block.end - block.begin + 1)
			blocks.append(block)
			if begin["point"] == bytes.size():
				# 到达末尾，则直接结束
				break
		
		# 块结尾
		var end = BlockType.find_block_end(bytes, begin["point"], begin["token"])
		var block = Block.new(bytes, point)
		block.begin = begin["point"]
		block.end = end["point"]
		block.text = text.substr(block.begin, block.end - block.begin + 1)
		blocks.append(block)
		point = end["point"] + 1
	
	return blocks


static func find_block_begin(bytes: PackedByteArray, current_point: int):
	var token : int
	while current_point < bytes.size():
		token = get_token(bytes, current_point)
		if token != Token.TEXT:
			current_point -= 1
			break
		current_point += 1
	return {
		"token": token,
		"point": current_point,
	}

static func find_block_end(bytes: PackedByteArray, current_point: int, token: int):
	while current_point < bytes.size():
		if is_token_end(bytes, current_point, token):
			break
		current_point += 1
	return {
		"point": current_point,
	}


# 获取当前 token 类型
static func get_token(bytes: PackedByteArray, current_point: int) -> int:
	if KeywordBegin.has(bytes[current_point]):
		if (bytes[current_point] == KEY_BRACKETLEFT # [
			or (
				bytes[current_point] == KEY_EXCLAM 
				and current_point + 1 < bytes.size() 
				and bytes[current_point + 1] == KEY_BRACKETLEFT
			) # ![
		):
			return Token.IMAGE
			
		elif bytes[current_point] == KEY_LESS: # <
			return Token.LINK
	
	return Token.TEXT


# 是 token 尾。token 中 TEXT, IMAGE, LINK 可以用这个方法
static func is_token_end(bytes: PackedByteArray, current_point: int, token: int) -> bool:
	if KeywordEnd.has(bytes[current_point]):
		match token:
			Token.TEXT:
				return current_point + 1 < bytes.size() and (
					bytes[current_point + 1] in [KEY_LESS, KEY_BRACKETLEFT] # < 或 [
					or (bytes[current_point] == KEY_EXCLAM  # ![
						and bytes[current_point + 1] == KEY_BRACKETLEFT
					)
				)
			Token.IMAGE:
				return bytes[current_point] == KEY_PARENRIGHT # 格式 ![]() 所以结尾是 )
			
			Token.LINK:
				return bytes[current_point] == KEY_GREATER # >
	
	return false


