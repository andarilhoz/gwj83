class_name EnemyAttack
extends Node

var player: Node2D
@export var bounce_distance: float = 6.0
@export var bounce_duration: float = 0.15
@export var cooldown: float = 1.0
@export var attack_sound: AudioStream
@export var damage_percent: float = 0.1  # 20% da energia máxima



var is_attacking = false
var attack_timer = 0.0
var anim: AnimatedSprite2D
var origin_node: Node2D  # onde a sprite está
var enemy_script: Enemy

# Em vez de attack_sound.play()

func _ready():
	origin_node = get_parent()
	anim = origin_node.get_node("AnimatedSprite2D")


func _process(delta):
	if attack_timer > 0:
		attack_timer -= delta

func can_attack() -> bool:
	return attack_timer <= 0 and !is_attacking and !enemy_script.is_afraid

func attack(direction: Vector2):
	if !can_attack():
		return

	is_attacking = true
	attack_timer = cooldown

	var original_position = anim.position
	var target_position = original_position + direction * bounce_distance

	await get_tree().process_frame  # Espera um frame

	set_process(false)
	var tween = create_tween()
	tween.tween_property(anim, "position", target_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim, "position", original_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.connect("finished", Callable(self, "efetua_ataque"))
	anim.play("Attack")
	EnemySound_Manager.play_attack_sound(attack_sound, origin_node.global_position)
	await tween.finished
	anim.play("Walk")

	anim.position = Vector2.ZERO
	is_attacking = false
	set_process(true)



func _on_tween_finished():
	anim.position = Vector2.ZERO
	set_process(true)
	is_attacking = false
	

func efetua_ataque() -> void:
	var player_script = player as PlayerScript
	if player_script.dashing :
		print("Player is dashing")
		return
	else: player_script.energy_component.take_damage(damage_percent, player)
