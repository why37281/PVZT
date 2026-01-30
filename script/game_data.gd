# GameData.gd
extends Node

var chapter_now: int
var level_now: int

# 存储所有章节数据
var chapters: Array[ChapterResource] = []

# 存储所有关卡数据 (key: "chapter_level")
var all_levels: Dictionary = {}

func load_all_data():
	print("📂 开始加载游戏数据...")
	
	#load_chapters()
	#load_levels()
	#apply_save_data()  # 应用存档数据
	
	print("✅ 数据加载完成")
	print("   章节数:", chapters.size())
	print("   关卡数:", all_levels.size())
