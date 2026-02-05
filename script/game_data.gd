extends Node

var chapter_now: int
var level_now: int

## 存储所有章节数据
var chapters: Array[ChapterResource] = []

## 存储所有关卡数据 [b](key: [code inline=true]chapter_level[/code])[/b]
var all_levels: Dictionary = {}

var save_data = {}
	#"version": 1,
	#"chapters_finishing": {},
	#"levels_finishing": {},
	#"settings": {
		#"volume_master": 1.0,
		#"volume_music": 0.8,
		#"volume_sfx": 1.0
	#}

var auto_settings = {
	
}

func _ready() -> void:
	load_all_data()
	apply_save_data()

func apply_save_data() -> void:
	SaveSystem.load_game_data(save_data)
	if save_data.is_empty():
		save_data["version"] = 1;
		save_data["settings"] = auto_settings
		save_data["levels_finishing"] = {}
		save_data["chapters_finishing"] = {}
		for level in all_levels:
			save_data["levels_finishing"][level] = false
			save_data["chapters_finishing"][all_levels[level].chapter_id] = false
	if save_data["version"] > 1:
		save_data["version"] += 1
	for chapter in chapters:
		save_data["chapters_finishing"][chapter.chapter_id] = \
		save_data["chapters_finishing"].get(chapter.chapter_id, false)
	for level in all_levels:
		save_data["levels_finishing"][level] = save_data["levels_finishing"].get(level, false)
func load_all_data():
	print("📂 开始加载游戏数据...")
	
	load_chapters()
	load_levels()
	#apply_save_data()  # 应用存档数据
	
	print("✅ 数据加载完成")
	print("   章节数:", chapters.size())
	print("   关卡数:", all_levels.size())
	print(all_levels, chapters)



func load_chapters():
	chapters.clear()
	
	var chapters_folder = "res://data/chapters/"
	var dir = DirAccess.open(chapters_folder)
	
	if not dir:
		print("❌ 章节文件夹不存在: ", chapters_folder)
		#create_default_chapter()  # 创建默认章节
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
		print("   ⚠️ 没有找到章节文件")
		#create_default_chapter()
	
	# 按章节ID排序
	chapters.sort_custom(func(a, b): return a.chapter_id < b.chapter_id)
	

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
