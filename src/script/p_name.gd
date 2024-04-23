#============================================================
#    Pname
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-22 11:18:18
# - version: 4.3.0.dev5
#============================================================
## 常量数据
class_name PName


enum LineType {
	Normal = 0, ## 普通行
	
	Colon = 10001, ## 冒号
	SerialNumber, ## 序号
	Checkbox, ## 复选框
	Quote, ## 引用
	Tag, ## 标签
	SeparationLine, ## 分隔线
	Code, ## 代码
	
	Tile_Larger = 20001, ## 大标题
	Tile_Medium, ## 中等标题
	Tile_Small, ## 小标题
	Center, ## 居中
}


## 数据分隔
const DATA_SPLIT_CHAR = char(0xfffff)


