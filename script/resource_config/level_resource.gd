# LevelResource.gd
extends Resource
class_name LevelResource
## 章节编号
@export var chapter_id: int
## 关卡编号
@export var level_id: int
## 关卡名称
@export var level_name: String
## 关卡描述
@export_multiline var description: String
## 关卡场景
@export var scene_path: PackedScene
## 略缩图
@export var preview_image: Texture2D
## 初始阳光
@export var sun_start: int = 50
## 僵尸波数
@export var zombie_waves: int
## 僵尸出现配置
@export var zombie_config: LevelZombieConfig
