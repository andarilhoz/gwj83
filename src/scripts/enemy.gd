extends CharacterBody2D

@onready var player = %Player
@export var speed = 200
@export var stop_distance: float = 64.0  # raio de parada
@onready var anim = $AnimatedSprite2D
var walk_timer: float = 0.0


func _physics_process(delta):
	if !player:
		return

	var to_player : Vector2 = player.global_position - global_position
	anim.flip_h = player.global_position.x < global_position.x
	var distance : float = to_player.length()

	if distance > stop_distance:
		var direction : Vector2 = to_player.normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
		
func _process(delta):
	update_sprite_bounce(delta)
	

func update_sprite_bounce(delta):
	if velocity.length() > 1:
		walk_timer += delta * 10
		anim.position.y = sin(walk_timer) * 1.5
		anim.rotation = sin(walk_timer) * deg_to_rad(3)
	else:
		anim.position.y = 0
		anim.rotation = 0
		walk_timer = 0
