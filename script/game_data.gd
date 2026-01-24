# GameData.gd
extends Node

## 当前选中的章节和关卡
var current_chapter_id: int = 1
var current_level_id: int = 1

## 所有章节数据
var chapters: Array[ChapterResource] = []
## 所有关卡数据 (key: "chapter_level")
var all_levels: Dictionary = {}

func _ready():
	load_all_data()
	print("✅ GameData 初始化完成")

# ==================== 数据加载 ====================
## 加载所有数据
func load_all_data():
	print("📂 开始加载游戏数据...")
	
	load_chapters()
	load_levels()
	apply_save_data()
	
	print("📂 数据加载完成")
	print("   章节数: %d" % chapters.size())
	print("   关卡数: %d" % all_levels.size())

## 加载所有章节
func load_chapters():
	chapters.clear()
	
	var chapters_folder = "res://data/chapters/"
	var dir = DirAccess.open(chapters_folder)
	
	if not dir:
		print("❌ 章节文件夹不存在: ", chapters_folder)
		create_default_chapter()  # 创建默认章节
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var loaded_count = 0
	
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
		print("   ⚠️ 没有找到章节文件，创建默认章节")
		create_default_chapter()
	
	# 按章节ID排序
	chapters.sort_custom(func(a, b): return a.chapter_id < b.chapter_id)
	print("   已加载 %d 个章节" % loaded_count)

## 加载所有关卡
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
	
	while folder_name != "":
		if dir.current_is_dir() and folder_name.begins_with("chapter_"):
			# 提取章节ID
			var chapter_num = folder_name.replace("chapter_", "")
			if chapter_num.is_valid_int():
				var chapter_id = chapter_num.to_int()
				
				# 加载这个章节的所有关卡
				var chapter_dir = DirAccess.open(levels_folder + folder_name + "/")
				if chapter_dir:
					chapter_dir.list_dir_begin()
					var level_file = chapter_dir.get_next()
					
					while level_file != "":
						if level_file.ends_with(".tres"):
							var level_path = levels_folder + "%s/%s" % [folder_name, level_file]
							var level = load(level_path) as LevelResource
							
							if level:
								var key = "%d_%d" % [level.chapter_id, level.level_id]
								all_levels[key] = level
								loaded_count += 1
								print("   加载关卡: %s (ID: %d-%d)" % [
									level.level_name, level.chapter_id, level.level_id
								])
						
						level_file = chapter_dir.get_next()
		
		folder_name = dir.get_next()
	
	print("   已加载 %d 个关卡" % loaded_count)

## 应用存档数据到资源
func apply_save_data():
	print("🔄 应用存档数据...")
	
	for chapter in chapters:
		# 设置章节解锁状态
		chapter.unlocked = SaveSystem.is_chapter_unlocked(chapter.chapter_id)
		
		# 收集本章节的所有关卡
		var chapter_levels = []
		for key in all_levels:
			var level = all_levels[key]
			if level.chapter_id == chapter.chapter_id:
				# 设置关卡状态
				level.unlocked = SaveSystem.is_level_unlocked(chapter.chapter_id, level.level_id)
				level.completed = SaveSystem.is_level_completed(chapter.chapter_id, level.level_id)
				level.stars = SaveSystem.get_level_stars(chapter.chapter_id, level.level_id)
				chapter_levels.append(level)
		
		# 按关卡ID排序
		chapter_levels.sort_custom(func(a, b): return a.level_id < b.level_id)
		chapter.levels = chapter_levels
		
		# 更新章节完成度
		var progress = chapter.update_progress()
		print("   章节 %d: 解锁=%s, 进度=%d/%d, 星星=%d" % [
			chapter.chapter_id,
			chapter.unlocked,
			progress.completed_levels,
			progress.total_levels,
			progress.total_stars
		])
	
	print("✅ 存档数据应用完成")

# ==================== 数据获取 ====================
## 获取章节
func get_chapter(chapter_id: int) -> ChapterResource:
	for chapter in chapters:
		if chapter.chapter_id == chapter_id:
			return chapter
	return null

## 获取关卡
func get_level(chapter_id: int, level_id: int) -> LevelResource:
	var key = "%d_%d" % [chapter_id, level_id]
	return all_levels.get(key)

## 获取当前章节
func get_current_chapter() -> ChapterResource:
	return get_chapter(current_chapter_id)

## 获取当前关卡
func get_current_level() -> LevelResource:
	return get_level(current_chapter_id, current_level_id)

## 获取章节总数
func get_chapter_count() -> int:
	return chapters.size()

## 获取关卡总数
func get_total_level_count() -> int:
	return all_levels.size()

# ==================== 游戏逻辑 ====================
## 完成当前关卡
func complete_current_level(stars: int = 1):
	var level = get_current_level()
	if level:
		# 更新关卡状态
		level.complete_with_stars(stars)
		
		# 保存到存档
		SaveSystem.complete_level(current_chapter_id, current_level_id, stars)
		
		# 检查是否解锁下一章
		check_unlock_next_chapter()
		
		print("🎉 完成关卡: %s (★%d)" % [level.level_name, stars])

## 检查是否解锁下一章
func check_unlock_next_chapter():
	var chapter = get_current_chapter()
	if chapter and chapter.completed:
		var next_chapter_id = current_chapter_id + 1
		var next_chapter = get_chapter(next_chapter_id)
		
		if next_chapter and not next_chapter.unlocked:
			SaveSystem.unlock_chapter(next_chapter_id)
			next_chapter.unlocked = true
			print("🔓 解锁新章节: %s" % next_chapter.chapter_name)

## 重置当前进度
func reset_current_progress():
	SaveSystem.reset_save()
	apply_save_data()
	print("🔄 进度已重置")

# ==================== 工具方法 ====================
## 创建默认章节（用于测试）
func create_default_chapter():
	print("📝 创建默认章节...")
	
	# 创建默认章节资源
	var chapter = ChapterResource.new()
	chapter.chapter_id = 1
	chapter.chapter_name = "入门教程"
	chapter.chapter_description = "学习植物大战僵尸的基本玩法"
	chapter.unlocked = true
	
	# 创建默认关卡
	var level = LevelResource.new()
	level.level_id = 1
	level.chapter_id = 1
	level.level_name = "第一天"
	level.description = "在阳光下开始你的冒险！"
	level.unlocked = true
	
	chapter.levels = [level]
	chapters.append(chapter)
	
	# 保存到字典
	all_levels["1_1"] = level
	
	print("   已创建默认章节和关卡")

## 调试信息
func print_debug_info():
	print("\n=== GameData 调试信息 ===")
	print("当前章节: %d" % current_chapter_id)
	print("当前关卡: %d" % current_level_id)
	print("章节总数: %d" % chapters.size())
	print("关卡总数: %d" % all_levels.size())
	
	for chapter in chapters:
		var progress = chapter.update_progress()
		print("章节 %d (%s):" % [chapter.chapter_id, chapter.chapter_name])
		print("  解锁: %s, 完成: %s" % [chapter.unlocked, chapter.completed])
		print("  进度: %d/%d" % [progress.completed_levels, progress.total_levels])
		
		for level in chapter.levels:
			print("  关卡 %d: 解锁=%s, 完成=%s, 星星=%d" % [
				level.level_id, level.unlocked, level.completed, level.stars
			])
