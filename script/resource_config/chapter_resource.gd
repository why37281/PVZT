extends Resource
class_name ChapterResource

@export var chapter_id: int
@export var chapter_name: String
@export var chapter_icon: Texture2D
@export_multiline var chapter_description: String
@export var unlocked: bool = false
@export var completed: bool = false
@export var levels: Array[LevelResource] = []  # 包含的关卡

## 更新章节进度信息
## 计算本章节中所有关卡的完成状态和星级统计
## 返回值: Dictionary 包含章节进度信息的字典
##   - completed_levels: int 已完成的关卡数量
##   - total_levels: int 总关卡数量
func update_progress():
	# 获取本章节包含的关卡总数
	var total_levels = levels.size()
	
	# 如果没有关卡，直接返回空字典
	if total_levels == 0:
		return {}
	
	# 初始化统计变量
	var completed_levels = 0  # 已完成的关卡数
	
	# 遍历所有关卡，统计完成情况和星星
	for level in levels:
		if level.completed:               # 关卡是否已完成
			completed_levels += 1         # 完成关卡计数+1
	
	# 如果所有关卡都已完成，标记整个章节为完成状态
	if completed_levels == total_levels:
		completed = true
	
	# 返回进度信息字典，供UI显示或其他系统使用
	return {
		"completed_levels": completed_levels,  # 已完成的关卡数
		"total_levels": total_levels,          # 总关卡数
	}
