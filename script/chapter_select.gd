extends CanvasLayer

func _ready() -> void:
	create_chapter_buttons()
	
func _process(delta: float) -> void:
	pass

func on_back_pressed():
	get_tree().change_scene_to_file("res://scene/start_menu.tscn")

func create_chapter_buttons():
	var grid = $ChaptersScroll/ChaptersGrid

	for child in grid.get_children():
		child.queue_free()
	
	# 从GameData获取章节数据
	for chapter in GameData.chapters:
		# 实例化按钮预制体
		var button = preload("res://scene/chapter_button.tscn").instantiate()
		
		# 设置按钮属性
		button.chapter_id = chapter.chapter_id
		button.chapter_name = chapter.chapter_name
		
		# 如果章节未解锁，禁用按钮
		if not chapter.unlocked:
			button.disabled = true
		
		# 添加到网格
		grid.add_child(button)

func _on_back_pressed():
	# 返回开始菜单
	get_tree().change_scene_to_file("res://scene/start_menu.tscn")
