extends Node

# 保存游戏数据
func save_game_data() -> bool:
	var save_data = GameData.data
	
	if not save_data:
		push_error("GameData.data 为空，无法保存！")
		return false
	
	# 创建保存目录路径
	
	var save_dir = Path.get_dir() + "/saves/"
	var save_path = _get_save_name()
	
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
	
	# 保存数据
	file.store_var(save_data)
	file.close()
	
	print("游戏已保存到: " + save_path)
	return true

func _get_save_index(save_dir:String) -> int:
	var index = 1
	while FileAccess.file_exists(save_dir + "save_" + str(index) + ".dat"):
		index += 1
	return index

func _get_save_name() -> String:
	var save_dir = Path.get_dir() + "/saves/"
	return save_dir + "save_" + str(1) + ".dat"

func load_game_data() -> bool:
	var save_path = _get_save_name()
	
	# 检查文件是否存在
	if not FileAccess.file_exists(save_path):
		return false
	
	# 读取文件
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	
	# 获取数据
	var save_data = file.get_var()
	file.close()
	
	# 验证并应用数据
	if save_data != null and save_data is Dictionary:
		GameData.data = save_data
		return true
	
	return false
