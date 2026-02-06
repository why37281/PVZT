extends CanvasLayer

func _ready() -> void:
	# 场景加载时，动态创建所有章节按钮
	create_chapter_buttons()

func create_chapter_buttons():
	"""
	动态创建并显示所有章节选择按钮.
	会先清除所有现有按钮, 然后根据GameData中的章节数据重新生成.
	"""
	var grid = $ScrollContainer/ChaptersGrid

	# 清理旧按钮，防止重复创建
	for child in grid.get_children():
		child.queue_free()
	
	# 从GameData获取所有章节数据并创建按钮
	for chapter in GameData.chapters:
		# 实例化按钮场景
		var button = preload("res://scene/chapter_button.tscn").instantiate()
		
		# 设置按钮的基本属性
		button.chapter_id = chapter.chapter_id
		button.chapter_name = chapter.chapter_name
		# 设置按钮图标
		button.texture = chapter.chapter_icon
		
		# 检查章节是否解锁, 如果未解锁, 则禁用按钮
		# 注意: GameData的存档数据使用字符串ID作为键, 以保证类型统一
		var chapter_id_str = str(chapter.chapter_id)
		if not GameData.save_data["chapters_unlocked"].get(chapter_id_str, false):
			button.disabled = true
		
		# 将创建的按钮添加到网格容器中
		grid.add_child(button)

func _on_back_pressed():
	# "返回"按钮被按下时，切换回开始菜单场景
	get_tree().change_scene_to_file("res://scene/start_menu.tscn")

# Note: The on_back_pressed function seems to be disconnected from the signal in the latest .tscn,
# but _on_back_pressed is connected. You might want to consolidate them.
func on_back_pressed():
	get_tree().change_scene_to_file("res://scene/start_menu.tscn")
