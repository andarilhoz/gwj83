extends Node2D

@export var player: CharacterBody2D
@export var enemy_scene: PackedScene

@export_range(0, 10000) var spawn_radius_level_1: float = 300.0
@export_range(0, 10000) var spawn_radius_level_2: float = 300.0
@export_range(0, 10000) var spawn_radius_level_3: float = 300.0

@export var max_enemies: int = 10
@export var min_enemies: int = 3
@export var spawn_rate: float = 2.0 # segundos entre spawns
@export var spawn_table: EnemySpawnSet


var _current_enemies: Array = []
var _spawn_timer: Timer

func _ready():
	# Cria e inicia o timer de spawn
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_rate
	_spawn_timer.one_shot = false
	_spawn_timer.autostart = true
	add_child(_spawn_timer)
	_spawn_timer.timeout.connect(_on_spawn_timeout)


func get_spawn_radious() -> float:
	match player.level:
		1: return spawn_radius_level_1
		2: return spawn_radius_level_2
		3: return spawn_radius_level_3
		_: return spawn_radius_level_1

func _on_spawn_timeout():
	if _current_enemies.size() >= max_enemies:
		return
	
	var to_spawn = randi_range(min_enemies, max_enemies - _current_enemies.size())
	for i in to_spawn:
		spawn()

func spawn():
	if not player or not spawn_table:
		return

	var pool: Array[EnemySpawnEntry] = spawn_table.get_pool_for_level(player.level)
	if pool.is_empty():
		return

	var chosen_entry: EnemySpawnEntry = pick_weighted_entry(pool)
	if not chosen_entry or not chosen_entry.scene:
		return

	var angle = randf() * TAU
	var spawn_radius = get_spawn_radious()
	var distance = randf_range(0.5 * spawn_radius, spawn_radius)
	var offset = Vector2.RIGHT.rotated(angle) * distance

	var enemy_instance = chosen_entry.scene.instantiate()
	enemy_instance.global_position = player.global_position + offset
	add_child(enemy_instance)
	_current_enemies.append(enemy_instance)

	var enemy_script = enemy_instance as Enemy
	if enemy_script:
		enemy_script.initialize(player)

	if enemy_instance.has_signal("died"):
		enemy_instance.died.connect(func():
			_current_enemies.erase(enemy_instance)
			enemy_instance.queue_free()
		)

func pick_weighted_entry(entries: Array[EnemySpawnEntry]) -> EnemySpawnEntry:
	var total := 0.0
	for entry in entries:
		total += entry.weight

	var rand_value := randf() * total
	var acc := 0.0

	for entry in entries:
		acc += entry.weight
		if rand_value <= acc:
			return entry

	return null
