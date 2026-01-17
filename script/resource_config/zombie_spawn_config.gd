extends Resource
class_name ZombieSpawnConfig

# 僵尸类型
@export var zombie_type: Enums.ZombieType = Enums.ZombieType.NORMAL

# 出现概率 (0.0-1.0)
@export_range(0.0, 1.0) var spawn_probability: float = 1.0

# 数量范围
@export_range(1, 100) var min_count: int = 1
@export_range(1, 100) var max_count: int = 1

# 出现间隔 (秒)
@export_range(0.1, 10.0) var spawn_interval: float = 1.0

# 可选：是否在特定行出现
@export var specific_rows: Array[int] = []  # 空数组表示所有行

# 生成僵尸数量的方法
func get_spawn_count() -> int:
	if min_count == max_count:
		return min_count
	return randi_range(min_count, max_count)

# 检查是否应该生成
func should_spawn() -> bool:
	return randf() <= spawn_probability
