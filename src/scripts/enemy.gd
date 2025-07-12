extends CharacterBody2D

@onready var player = %Player
@export var speed = 50

func _process(delta):
	if !player:
		player = get_tree().get_root().find_child("Player", true, false)
		if player:
			print("Player encontrado DEPOIS:", player)

func _physics_process(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
