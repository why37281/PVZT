# game_data.gd
# 这是一个自动加载的单例脚本，作为游戏数据的中心枢纽。
# 它负责加载、管理和存储所有与游戏进度相关的数据，例如章节、关卡信息和玩家存档。
# 通过这种方式，游戏的其他部分可以方便地访问和修改游戏状态。
extends Node

# 当前玩家所在的章节ID
var chapter_now: int
# 当前玩家所在的关卡ID
var level_now: int

## 存储从 "res://data/chapters/" 目录加载的所有章节资源 (ChapterResource)
var chapters: Array[ChapterResource] = []

## 存储所有关卡的字典。
## key: 字符串，格式为 "章节ID_关卡ID" (例如 "1_1")
## value: 关卡资源 (LevelResource)
var all_levels: Dictionary = {}

## 存储玩家的存档数据。游戏启动时从文件加载，关闭时保存。
var save_data = {}
	# 存档数据结构示例:
	# "version": 1,  // 存档版本，用于未来的数据迁移
	# "chapters_unlocked": {"1": true, "2": false}, // 章节解锁状态
	# "levels_unlocked": {"1_1": true, "1_2": false},   // 关卡解锁状态
	# "chapters_finishing": {"1": true, "2": false}, // 章节完成状态
	# "levels_finishing": {"1_1": true, "1_2": false},   // 关卡完成状态
	# "settings": { ... } // 音量等设置

# 默认设置，当没有存档时使用
var auto_settings = {
	
}

func update_chapter_level_status():
	update_chapters_finishing()
	update_chapters_unlocked()

func update_chapters_unlocked():
	var index = 0
	for chapter in chapters:
		if index != 0:
			if save_data["chapters_finishing"][chapters[index - 1].chapter_id]:
				save_data["chapters_unlocked"][chapter.chapter_id] = true
	index += 1

# 更新所有章节的完成状态
# 遍历所有章节，如果一个章节下的所有关卡都已完成，则将该章节标记为完成。
func update_chapters_finishing():
	for chapter in chapters:
		
		save_data["chapters_finishing"][chapter.chapter_id] = \
		check_chapter_finish(chapter.chapter_id)

# 检查指定章节是否已经完成
# - chapter: 要检查的章节ID
# - 返回: 如果该章节所有关卡都已完成，返回 true；否则返回 false。
func check_chapter_finish(chapter: int) -> bool:
	var chapter_name
	for level in all_levels:
		chapter_name = level.split("_")[0]
		# 如果关卡属于该章节，并且尚未完成
		if int(chapter_name) == chapter and \
		not save_data["levels_finishing"].get(level, false):
			return false # 则该章节未完成
	return true # 所有关卡都已完成

# Godot生命周期函数，当节点进入场景树时调用。
# 这是初始化游戏数据的入口点。
func _ready() -> void:
	load_all_data()
	apply_save_data()

# 应用存档数据。如果不存在存档，则创建一份新的默认存档。
func apply_save_data() -> void:
	# 从文件系统加载存档
	SaveSystem.load_game_data(save_data)
	
	# 如果存档为空，说明是第一次游戏，需要初始化
	if save_data.is_empty():
		save_data["version"] = 1;
		save_data["settings"] = auto_settings
		save_data["levels_unlocked"] = {}
		save_data["chapters_unlocked"] = {}
		save_data["levels_finishing"] = {}
		save_data["chapters_finishing"] = {}
		
		# 为所有已加载的关卡和章节设置默认的“未解锁”和“未完成”状态
		for level in all_levels:
			save_data["levels_unlocked"][level] = false
			save_data["chapters_unlocked"][all_levels[level].chapter_id] = false
			save_data["levels_finishing"][level] = false
			save_data["chapters_finishing"][all_levels[level].chapter_id] = false
			
	# 存档版本升级（为未来扩展做准备）
	if save_data["version"] > 1:
		save_data["version"] += 1
		
	# 确保至少有一个章节是解锁的（通常是第一章）
	var min_chapter_id = 10^8
	for chapter in chapters:
		min_chapter_id = min(chapter.chapter_id, min_chapter_id)
		# 确保存档中包含所有已加载的章节，没有则设为默认值false
		save_data["chapters_unlocked"][chapter.chapter_id] = \
		save_data["chapters_unlocked"].get(chapter.chapter_id, false)
	# 默认解锁ID最小的章节
	save_data["chapters_unlocked"][min_chapter_id] = true
	var min_level_id = 10^8
	# 确保存档中包含所有已加载的关卡
	for level in all_levels:
		save_data["levels_unlocked"][level] = save_data["levels_unlocked"].get(level, false)
		if level.split("_")[0] == str(min_chapter_id):
			min_level_id = min(min_level_id, int(level.split("_")[1]))
	save_data["levels_unlocked"]["%d_%d" % [min_level_id, min_chapter_id]] = true
# 加载所有游戏核心数据（章节和关卡）
func load_all_data():
	print("📂 开始加载游戏数据...")
	
	load_chapters()
	load_levels()
	#apply_save_data()  # 应用存档数据
	
	print("✅ 数据加载完成")
	print("   章节数:", chapters.size())
	print("   关卡数:", all_levels.size())
	print(all_levels, chapters)



# 从 "res://data/chapters/" 文件夹加载所有章节资源文件 (.tres)
func load_chapters():
	chapters.clear()
	
	var chapters_folder = "res://data/chapters/"
	var dir = DirAccess.open(chapters_folder)
	
	if not dir:
		print("❌ 章节文件夹不存在: ", chapters_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var loaded_count = 0
	
	# 遍历文件夹中的所有文件
	while file_name != "":
		if file_name.ends_with(".tres"):
			var chapter_path = chapters_folder + file_name
			var chapter = load(chapter_path) as ChapterResource
			
			if chapter:
				chapters.append(chapter)
				loaded_count += 1
				print("   加载章节: %s (ID: %d)" % [chapter.chapter_name, chapter.chapter_id])
			else:
				print("   ❌ 加载失败: ", chapter_path)
		
		file_name = dir.get_next()
	
	if loaded_count == 0:
		print("   ⚠️ 没有找到章节文件")
	
	# 按章节ID对加载的章节进行排序，确保顺序正确
	chapters.sort_custom(func(a, b): return a.chapter_id < b.chapter_id)
	

# 从 "res://data/levels/" 文件夹加载所有关卡资源文件 (.tres)
# 关卡文件按章节存放在 "chapter_X" 子文件夹中。
func load_levels():
	all_levels.clear()
	
	var levels_folder = "res://data/levels/"
	var dir = DirAccess.open(levels_folder)
	
	if not dir:
		print("❌ 关卡文件夹不存在: ", levels_folder)
		return
	
	dir.list_dir_begin()
	var folder_name = dir.get_next()
	var loaded_count = 0
	
	# 遍历关卡根目录下的所有子文件夹
	while folder_name != "":
		if dir.current_is_dir() and folder_name.begins_with("chapter_"):
			# 从文件夹名称提取章节ID
			var chapter_num = folder_name.replace("chapter_", "")
			if chapter_num.is_valid_int():
				
				# 加载这个章节文件夹内的所有关卡文件
				var chapter_dir_path = levels_folder + folder_name + "/"
				var chapter_dir = DirAccess.open(chapter_dir_path)
				if chapter_dir:
					chapter_dir.list_dir_begin()
					var level_file = chapter_dir.get_next()
					
					while level_file != "":
						if level_file.ends_with(".tres"):
							var level_path = "%s%s/%s" % [levels_folder, folder_name, level_file]
							var level = load(level_path) as LevelResource
							
							if level:
								# 使用 "章节ID_关卡ID" 作为唯一键
								var key = "%d_%d" % [level.chapter_id, level.level_id]
								all_levels[key] = level
								loaded_count += 1
								print("   加载关卡: %s (ID: %d-%d)" % [
									level.level_name, level.chapter_id, level.level_id
								])
						
						level_file = chapter_dir.get_next()
		
		folder_name = dir.get_next()
	
	print("   已加载 %d 个关卡" % loaded_count)
