extends Node

func apply_save_data_to_gamedata():
	if not GameData:
		print("❌ GameData 未初始化")
		return
	
	print("🔄 应用存档数据到GameData...")
	
	for chapter in GameData.chapters:
		# 设置章节解锁状态
		
		
		# 收集本章节的所有关卡
		var chapter_levels = []
		for key in GameData.all_levels:
			var level = GameData.all_levels[key]
			if level.chapter_id == chapter.chapter_id:
				# 设置关卡状态
				
				chapter_levels.append(level)
		
		# 按关卡ID排序
		chapter_levels.sort_custom(func(a, b): return a.level_id < b.level_id)
		chapter.levels = chapter_levels
		
		# 更新章节完成度
		var progress = chapter.update_progress()
		print("   章节 %d: 解锁=%s, 进度=%d/%d" % [
			chapter.chapter_id,
			chapter.unlocked,
			progress.get("completed_levels", 0),
			progress.get("total_levels", 0)
		])
	
	print("✅ 存档数据应用完成")

# 保存游戏数据
func save_game_data(data_to_save: Dictionary, save_path: String = "", save_dir:String = "") -> bool:
	# 参数验证
	if not data_to_save:
		push_error("传入的数据为空，无法保存！")
		return false
		
	if save_path == "":
		save_path = Path.get_dir() + "/" + _get_save_name()
	if save_dir == "":
		save_dir = save_path.get_base_dir()
	
	
	# 创建保存目录（如果不存在）
	if not DirAccess.dir_exists_absolute(save_dir):
		var error = DirAccess.make_dir_recursive_absolute(save_dir)
		if error != OK:
			push_error("无法创建保存目录: " + save_dir)
			return false
	
	# 创建文件对象
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file == null:
		push_error("无法打开保存文件: " + save_path)
		return false
	
	# 保存传入的数据
	file.store_var(data_to_save)  # 修改：保存传入的参数
	file.close()
	
	print("游戏已保存到: " + save_path)
	return true

# 加载游戏数据
func load_game_data(data_reference: Dictionary, save_path: String = "") -> bool:
	if save_path == "":
		save_path = Path.get_dir() + "/save/" + "save_1.dat"
	
	# 检查文件是否存在
	if not FileAccess.file_exists(save_path):
		return false
	
	# 读取文件
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	
	# 获取数据
	var loaded_data = file.get_var()
	file.close()
	
	# 验证并应用数据到传入的引用
	if loaded_data != null and loaded_data is Dictionary:
		data_reference.clear()  # 清空原数据
		data_reference.merge(loaded_data)  # 合并新数据
		return true
	
	return false

func _get_save_index(save_dir:String) -> int:
	var index = 1
	while FileAccess.file_exists(save_dir + "save_" + str(index) + ".dat"):
		index += 1
	return index

func _get_save_name() -> String:
	return "save_1.dat"
