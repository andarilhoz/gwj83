extends CharacterBody2D

var player
@export var speed = 50

func _ready():
	player = get_node("../Player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
