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

	
func get_direction_to_player(player: CharacterBody2D) -> Vector2:
	var enemy_collider: CollisionShape2D = enemy.get_node("EnemyCollider")
	var player_collider: CollisionShape2D = player.get_node("CollisionShape2D")

	var enemy_shape: RectangleShape2D = enemy_collider.shape as RectangleShape2D
	var player_shape: CircleShape2D = player_collider.shape as CircleShape2D

	var enemy_shape_pos: Vector2 = enemy_collider.global_position
	var player_shape_pos: Vector2 = player_collider.global_position

	var enemy_half_extents: Vector2 = enemy_shape.extents
	var enemy_min: Vector2 = enemy_shape_pos - enemy_half_extents
	var enemy_max: Vector2 = enemy_shape_pos + enemy_half_extents

	# Ponto mais próximo do círculo no retângulo
	var closest_point: Vector2 = Vector2(
		clamp(player_shape_pos.x, enemy_min.x, enemy_max.x),
		clamp(player_shape_pos.y, enemy_min.y, enemy_max.y)
	)

	var player_scale: Vector2 = player.scale
	var scaled_radius: float = player_shape.radius * max(player_scale.x, player_scale.y)
	var distance_squared: float = player_shape_pos.distance_squared_to(closest_point)

	if distance_squared <= scaled_radius * scaled_radius:
		enemy.velocity = Vector2.ZERO
		return Vector2.ZERO

	var direction: Vector2 = (player_shape_pos - enemy_shape_pos).normalized()
	enemy.velocity = direction * speed
	return direction


func get_effective_radius(shape: Shape2D, direction: Vector2) -> float:
	if shape is CircleShape2D:
		return shape.radius
	elif shape is RectangleShape2D:
		var rect_shape = shape as RectangleShape2D
		var extents = rect_shape.extents
		var dir = direction.normalized()
		var projected = abs(dir.x) * extents.x + abs(dir.y) * extents.y
		return projected
	return 0.0

	
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
