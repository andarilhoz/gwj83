extends CharacterBody2D

@onready var player = %Player
@export var speed = 200
@export var stop_distance: float = 86.0  # raio de parada
@onready var anim = $AnimatedSprite2D
var walk_timer: float = 0.0

## Variaveis do Ataque do inimigo
@export var attack_cooldown: float = 1
@export var attack_bounce_distance: float = 6.0
@export var attack_bounce_speed: float = 20.0
@export var attack_bounce_duration: float = 0.15
var is_attacking = false
var attack_timer: float = 0.0


func _physics_process(delta):
	if !player or is_attacking:
		return

	var to_player: Vector2 = player.global_position - global_position
	anim.flip_h = player.global_position.x < global_position.x
	var distance = to_player.length()

	attack_timer -= delta

	if distance > stop_distance:
		var direction = to_player.normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

		if attack_timer <= 0:
			attack_player(to_player.normalized())
			


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


func attack_player(direction: Vector2):
	is_attacking = true
	attack_timer = attack_cooldown
	velocity = Vector2.ZERO

	var original_position = anim.position
	var target_position = original_position + direction * attack_bounce_distance

	set_process(false)

	var tween = create_tween()
	tween.tween_property(anim, "position", target_position, attack_bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim, "position", original_position, attack_bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished

	set_process(true)
	is_attacking = false
