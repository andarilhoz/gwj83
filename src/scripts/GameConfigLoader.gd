extends Node

var config: GameConfig = preload("res://src/Resource/GameConfig.tres")


func getLevelStats(level: int) -> LevelStats:
	match level:
		1: return GameConfigLoader.config.level_1_stats
		2: return GameConfigLoader.config.level_2_stats
		3: return GameConfigLoader.config.level_3_stats
		_: return GameConfigLoader.config.level_1_stats
