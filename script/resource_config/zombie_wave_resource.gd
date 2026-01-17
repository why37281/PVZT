extends Resource
class_name ZombieWaveResource

# 波次基本信息
@export var wave_id: int
@export var wave_name: String
@export_multiline var description: String
@export_range(1, 1000) var trigger_time: float = 10.0  # 触发时间(秒)

# 此波次的僵尸配置
@export var zombie_configs: Array[ZombieSpawnConfig] = []

# 波次完成条件
@export_range(1, 1000) var total_zombies_to_spawn: int = 10
# 波次结束后等待时间
@export var wave_complete_delay: float = 5.0

# 特殊效果


# 生成此波次的所有僵尸配置
func generate_zombies() -> Array[Dictionary]:
	var zombies_to_spawn = []
	
	for config in zombie_configs:
		if config.should_spawn():
			var count = config.get_spawn_count()
			for i in range(count):
				zombies_to_spawn.append({
					"type": config.zombie_type,
					"delay": i * config.spawn_interval,
					"row": _get_random_row(config.specific_rows)
				})
	
	return zombies_to_spawn

# 获取随机行
func _get_random_row(specific_rows: Array[int]) -> int:
	if specific_rows.is_empty():
		return randi_range(0, 4)  # 假设有5行草坪
	else:
		return specific_rows[randi() % specific_rows.size()]
