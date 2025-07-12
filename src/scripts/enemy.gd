extends CharacterBody2D

@onready var player = %Player
@export var speed = 50
@export var stop_distance: float = 16.0  # raio de parada

func _physics_process(delta):
	if player:
		var to_player = player.global_position - global_position
		var distance = to_player.length()

		if distance > stop_distance:
			var direction = to_player.normalized()
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
