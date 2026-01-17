extends Resource
class_name LevelZombieConfig

# 关卡基本信息
@export var level_id: int
@export var level_name: String

# 此关卡的所有波次
@export var waves: Array[ZombieWaveResource] = []

# 全局僵尸属性
@export_range(1.0, 3.0) var zombie_speed_multiplier: float = 1.0
@export_range(0.5, 2.0) var zombie_health_multiplier: float = 1.0
@export_range(0.5, 2.0) var zombie_damage_multiplier: float = 1.0

# 波次生成间隔
@export_range(5.0, 60.0) var wave_interval: float = 20.0

# 获取指定波次
func get_wave(wave_id: int) -> ZombieWaveResource:
	for wave in waves:
		if wave.wave_id == wave_id:
			return wave
	return null

# 获取波次总数
func get_total_waves() -> int:
	return waves.size()

# 获取下一个波次
func get_next_wave(current_wave: int) -> ZombieWaveResource:
	for wave in waves:
		if wave.wave_id > current_wave:
			return wave
	return null
