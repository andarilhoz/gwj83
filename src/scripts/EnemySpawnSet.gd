extends Resource
class_name EnemySpawnSet

@export var level_1_enemies: Array[EnemySpawnEntry]
@export var level_2_enemies: Array[EnemySpawnEntry]
@export var level_3_enemies: Array[EnemySpawnEntry]

func get_pool_for_level(level: int) -> Array[EnemySpawnEntry]:
	match level:
		1: return level_1_enemies
		2: return level_2_enemies
		3: return level_3_enemies
		_: return []
