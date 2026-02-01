extends Resource
class_name ChapterResource

@export var chapter_id: int
@export var chapter_name: String
@export var chapter_icon: Texture2D
@export_multiline var chapter_description: String
@export var completed: bool = false
@export var levels: Array[LevelResource] = []  # 包含的关卡
