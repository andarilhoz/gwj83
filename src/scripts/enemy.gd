extends CharacterBody2D

@onready var player = %Player
@export var speed = 200
@export var stop_distance: float = 64.0  # raio de parada

func _physics_process(delta):
	if !player:
		return

	var to_player : Vector2 = player.global_position - global_position
	var distance : float = to_player.length()

	if distance > stop_distance:
		var direction : Vector2 = to_player.normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
