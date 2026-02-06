extends CanvasLayer

@onready var grid = $ScrollContainer/LevelsGrid

func _ready():
	create_level_buttons()

func create_level_buttons():
	# 清空现有按钮
	for child in grid.get_children():
		child.queue_free()
		
	# 获取当前章节的所有关卡
	var current_chapter_id = GameData.chapter_now
	
	# 在 GameData.all_levels 中筛选属于当前章节的关卡
	var levels_to_show = []
	for key in GameData.all_levels:
		var level = GameData.all_levels[key]
		if level.chapter_id == current_chapter_id:
			levels_to_show.append(level)
	
	# 排序
	levels_to_show.sort_custom(func(a, b): return a.level_id < b.level_id)
	
	for level in levels_to_show:
		var btn = preload("res://scene/chapter_button.tscn").instantiate()
		btn.is_chapter = false
		btn.chapter_name = level.level_name
		btn.texture = level.preview_image
		btn.disabled = not GameData.save_data["levels_unlocked"]["%s_%s" % [level.chapter_id, level.level_id]]
		btn.pressed.connect(_on_level_selected.bind(level))
		grid.add_child(btn)

func _on_level_selected(level: LevelResource):
	GameData.level_now = level.level_id
	if level.scene_path:
		get_tree().change_scene_to_packed(level.scene_path)
	else:
		print("⚠️ 该关卡尚未配置场景路径！")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/chapter_select.tscn")
