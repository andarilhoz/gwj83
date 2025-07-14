extends Node

class_name EnemyMovementComponent

var speed: float = 200.0
var stop_distance: float = 86.0
var enemy: CharacterBody2D

func start(owner: CharacterBody2D, movement_speed: float, stop_dist: float):
	enemy = owner
	speed = movement_speed
	stop_distance = stop_dist

func move_towards_player(player: CharacterBody2D, delta: float) -> Vector2:
	if not enemy or not player:
		return Vector2.ZERO

	var to_player: Vector2 = player.global_position - enemy.global_position
	var distance: float = to_player.length()

	if distance > stop_distance:
		var direction: Vector2 = to_player.normalized()
		enemy.velocity = direction * speed
	else:
		enemy.velocity = Vector2.ZERO
	
	return to_player.normalized()
