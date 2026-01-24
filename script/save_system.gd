# SaveSystem.gd
extends Node

## 存档文件路径
const SAVE_PATH = "user://pvz_save.dat"
## 当前存档版本
const SAVE_VERSION = 1

# 存档数据结构
var save_data = {
	"version": SAVE_VERSION,
	"chapters": {},      # 章节解锁状态
	"levels": {},        # 关卡完成状态
	"settings": {        # 游戏设置
		"volume_master": 1.0,
		"volume_music": 0.8,
		"volume_sfx": 1.0,
		"fullscreen": true
	},
	"player_stats": {
		"total_play_time": 0
	},
	"last_play": {       # 最后游玩
		"chapter_id": 1,
		"level_id": 1,
		"timestamp": 0
	}
}

func _ready():
	# 游戏启动时加载存档
	load_game()

# ==================== 存档管理 ====================
## 保存游戏
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("✅ 游戏已保存")
	else:
		print("❌ 保存失败:", FileAccess.get_open_error())

## 加载游戏
func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var loaded_data = file.get_var()
			file.close()
			
			if loaded_data:
				merge_save_data(loaded_data)
				print("✅ 游戏已加载")
				return true
	else:
		print("📁 无存档文件，创建新存档")
		reset_save()  # 创建默认存档
	return false

## 合并存档数据（处理版本升级）
func merge_save_data(loaded_data: Dictionary):
	# 检查版本
	var loaded_version = loaded_data.get("version", 0)
	
	if loaded_version < SAVE_VERSION:
		print("🔄 升级存档版本: %d -> %d" % [loaded_version, SAVE_VERSION])
		# 这里可以添加版本迁移代码
	
	# 深度合并字典
	deep_merge(save_data, loaded_data)

## 深度合并字典
func deep_merge(target: Dictionary, source: Dictionary):
	for key in source:
		if key in target and typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
			# 递归合并字典
			deep_merge(target[key], source[key])
		else:
			target[key] = source[key]

## 重置存档（新游戏）
func reset_save():
	save_data = {
		"version": SAVE_VERSION,
		"chapters": {"1": {"unlocked": true}},  # 第一章默认解锁
		"levels": {},
		"settings": {
			"volume_master": 1.0,
			"volume_music": 0.8,
			"volume_sfx": 1.0,
			"fullscreen": true
		},
		"player_stats": {
			"total_sun_collected": 0,
			"zombies_killed": 0,
			"plants_planted": 0,
			"total_play_time": 0
		},
		"last_play": {
			"chapter_id": 1,
			"level_id": 1,
			"timestamp": 0
		}
	}
	save_game()
	print("🔄 存档已重置")

# ==================== 章节管理 ====================
## 解锁章节
func unlock_chapter(chapter_id: int):
	var chapter_key = str(chapter_id)
	
	if not save_data.chapters.has(chapter_key):
		save_data.chapters[chapter_key] = {}
	
	save_data.chapters[chapter_key]["unlocked"] = true
	save_data.chapters[chapter_key]["unlock_time"] = Time.get_unix_time_from_system()
	save_game()
	print("🔓 解锁章节:", chapter_id)

## 检查章节是否解锁
func is_chapter_unlocked(chapter_id: int) -> bool:
	if chapter_id == 1:  # 第一章默认解锁
		return true
	
	var chapter_key = str(chapter_id)
	if save_data.chapters.has(chapter_key):
		return save_data.chapters[chapter_key].get("unlocked", false)
	return false

# ==================== 关卡管理 ====================
## 完成关卡
func complete_level(chapter_id: int, level_id: int):
	var level_key = "%d_%d" % [chapter_id, level_id]
	
	if not save_data.levels.has(level_key):
		save_data.levels[level_key] = {}
	
	# 记录完成状态
	save_data.levels[level_key]["completed"] = true
	save_data.levels[level_key]["complete_time"] = Time.get_unix_time_from_system()
	save_data.levels[level_key]["attempts"] = save_data.levels[level_key].get("attempts", 0) + 1
	
	# 记录最后游玩
	save_data.last_play["chapter_id"] = chapter_id
	save_data.last_play["level_id"] = level_id
	save_data.last_play["timestamp"] = Time.get_unix_time_from_system()
	
	# 自动解锁下一关
	unlock_next_level(chapter_id, level_id)
	
	# 检查是否解锁下一章
	check_unlock_next_chapter(chapter_id)
	
	save_game()
	print("✅ 完成关卡: %d-%d" % [chapter_id, level_id])

## 检查关卡是否完成
func is_level_completed(chapter_id: int, level_id: int) -> bool:
	var level_key = "%d_%d" % [chapter_id, level_id]
	if save_data.levels.has(level_key):
		return save_data.levels[level_key].get("completed", false)
	return false

## 检查关卡是否解锁
func is_level_unlocked(chapter_id: int, level_id: int) -> bool:
	if level_id == 1:  # 每章第一关默认解锁
		return true
	
	var level_key = "%d_%d" % [chapter_id, level_id]
	if save_data.levels.has(level_key):
		return save_data.levels[level_key].get("unlocked", false)
	
	# 如果前一关完成，这关就解锁
	var prev_key = "%d_%d" % [chapter_id, level_id - 1]
	if save_data.levels.has(prev_key):
		return save_data.levels[prev_key].get("completed", false)
	
	return false

## 解锁下一关
func unlock_next_level(chapter_id: int, level_id: int):
	var next_key = "%d_%d" % [chapter_id, level_id + 1]
	if not save_data.levels.has(next_key):
		save_data.levels[next_key] = {}
	save_data.levels[next_key]["unlocked"] = true

## 检查是否解锁下一章
func check_unlock_next_chapter(chapter_id: int):
	# 这里可以添加逻辑：如果本章所有关卡都完成，解锁下一章
	# 暂时先不实现，等 GameData 加载后再处理
	pass

# ==================== 设置管理 ====================
## 保存设置
func save_setting(key: String, value):
	if save_data.settings.has(key):
		save_data.settings[key] = value
		save_game()

## 获取设置
func get_setting(key: String, default = null):
	return save_data.settings.get(key, default)

# ==================== 玩家统计 ====================
## 增加玩家统计
func add_player_stat(stat_key: String, value: int = 1):
	if not save_data.player_stats.has(stat_key):
		save_data.player_stats[stat_key] = 0
	save_data.player_stats[stat_key] += int(value)
	save_game()

## 获取玩家统计
func get_player_stat(stat_key: String) -> int:
	return save_data.player_stats.get(stat_key, 0)

# ==================== 工具方法 ====================
## 获取最后游玩的关卡
func get_last_played() -> Dictionary:
	return save_data.last_play.duplicate()

## 导出存档数据（用于调试）
func export_save_data() -> Dictionary:
	return save_data.duplicate(true)  # 深度复制

## 导入存档数据
func import_save_data(data: Dictionary):
	save_data = data
	save_game()
	print("📥 存档已导入")
