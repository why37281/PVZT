extends Button

@export var chapter_id: int = 1
@export var chapter_name: String = ""
@export var texture: Texture2D

func _ready():
	# 更新UI显示
	update_display()

func update_display():
	# 设置章节名称
	$VBoxContainer/VBoxContainer/Label.text = chapter_name
	$VBoxContainer/TextureRect.texture = texture

# 这里可以添加进度更新逻辑
# 比如从GameData获取进度信息
func _on_button_pressed():
	pass
