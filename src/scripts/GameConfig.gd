extends Resource
class_name GameConfig

@export_group("Níveis do Jogador")
@export var level_1_stats: LevelStats
@export var level_2_stats: LevelStats
@export var level_3_stats: LevelStats

@export_group("Configurações Gerais")
@export var player_initial_energy: float = 50.0
@export var min_player_scale: float = 0.3

@export_group("Energia fornecida por inimigos ao serem consumidos")
@export var enemy_level_1: float = 10
@export var enemy_level_2: float = 50
@export var enemy_level_3: float = 100

@export_group("Energia fornecida por consumíveis ao serem consumidos")
@export var consumable_level_1: float = 10
@export var consumable_level_2: float = 50
@export var consumable_level_3: float = 100
