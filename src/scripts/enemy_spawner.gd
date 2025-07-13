extends Node2D

@export var player: CharacterBody2D
@export var enemy_scene: PackedScene

@export_range(0, 10000) var spawn_radius: float = 300.0
@export var max_enemies: int = 10
@export var min_enemies: int = 3
@export var spawn_rate: float = 2.0 # segundos entre spawns

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

func _on_spawn_timeout():
	if _current_enemies.size() >= max_enemies:
		return
	
	var to_spawn = randi_range(min_enemies, max_enemies - _current_enemies.size())
	for i in to_spawn:
		spawn()

func spawn():
	if not player or not enemy_scene:
		return

	var angle = randf() * TAU
	var distance = randf_range(0.5 * spawn_radius, spawn_radius)
	var offset = Vector2.RIGHT.rotated(angle) * distance

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = player.global_position + offset
	add_child(enemy_instance)
	_current_enemies.append(enemy_instance)
	
	var enemy_script = enemy_instance as Enemy
	enemy_script.initialize(player)

	# Opcional: remover inimigos da lista quando morrerem
	if enemy_instance.has_signal("died"):
		enemy_instance.died.connect(func():
			_current_enemies.erase(enemy_instance)
			enemy_instance.queue_free()
		)
