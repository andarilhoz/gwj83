extends Node

class_name EnemyMovementComponent

@export var speed: float = 200.0
var stop_distance: float = 86.0
var enemy: CharacterBody2D
@export var afraid_distance: float = 250.0  # distância segura ao fugir
var idle_walk_target: Vector2 = Vector2.ZERO
@export var idle_wander_distance_min: float = 10.0
@export var idle_wander_distance_max: float = 80.0
@export var idle_walk_timer: float = 0.0
@export var idle_interval: float = 1.5  # tempo entre cada "passo"


func start(owner: CharacterBody2D, movement_speed: float, stop_dist: float):
	enemy = owner
	speed = movement_speed
	stop_distance = stop_dist

func move_towards_player(player: CharacterBody2D, delta: float, is_afraid := false) -> Vector2:
	if not enemy or not player:
		return Vector2.ZERO

	var to_player: Vector2 = player.global_position - enemy.global_position
	var distance: float = to_player.length()

	var direction: Vector2
	if is_afraid:
		if distance < afraid_distance:
			direction = -to_player.normalized()
			enemy.velocity = direction * speed
		else:
			enemy.velocity = Vector2.ZERO
	else:
		if distance > stop_distance:
			direction = to_player.normalized()
			enemy.velocity = direction * speed
		else:
			enemy.velocity = Vector2.ZERO

	return direction
	
func idle_wander(delta: float):
	idle_walk_timer -= delta

	if idle_walk_timer <= 0:
		idle_walk_timer = idle_interval
		var random_angle = randf_range(0, TAU)
		var random_offset = Vector2(cos(random_angle), sin(random_angle)) * randf_range(idle_wander_distance_min, idle_wander_distance_max)
		idle_walk_target = enemy.global_position + random_offset

	var to_target = idle_walk_target - enemy.global_position
	if to_target.length() > 2.0:
		var dir = to_target.normalized()
		enemy.velocity = dir * (speed * 0.25)  # velocidade reduzida no idle
	else:
		enemy.velocity = Vector2.ZERO
