extends Node

var player: Node2D
@export var bounce_distance: float = 6.0
@export var bounce_duration: float = 0.15
@export var cooldown: float = 1.0
var hitbox
@export var attack_sound: AudioStream
@export var damage_percent: float = 0.1  # 20% da energia máxima



var is_attacking = false
var attack_timer = 0.0
var anim: AnimatedSprite2D
var origin_node: Node2D  # onde a sprite está


# Em vez de attack_sound.play()



func _ready():
	origin_node = get_parent()
	anim = origin_node.get_node("AnimatedSprite2D")
	hitbox = origin_node.get_node("Attack_Hitbox")
	hitbox.connect("body_entered", Callable(self, "_on_attack_hitbox_body_entered")) # <- Corrigido


func _process(delta):
	if attack_timer > 0:
		attack_timer -= delta

func can_attack() -> bool:
	return attack_timer <= 0 and !is_attacking

func attack(direction: Vector2):
	if !can_attack():
		return

	is_attacking = true
	attack_timer = cooldown

	var original_position = anim.position
	var target_position = original_position + direction * bounce_distance

	# Posiciona a hitbox no jogador e espera um frame para a engine atualizar
	hitbox.global_position = player.global_position
	await get_tree().process_frame  # Espera um frame

	# Ativa a detecção da hitbox
	hitbox.monitoring = true
	hitbox.get_node("Attack Collider").disabled = false

	# Debug: checa se está detectando algo
	print("🔎 Hitbox overlapping:", hitbox.get_overlapping_bodies())
	print("🎯 Conectado?", hitbox.is_connected("body_entered", Callable(self, "_on_attack_hitbox_body_entered")))

	# Animação de ataque
	set_process(false)
	var tween = create_tween()
	tween.tween_property(anim, "position", target_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim, "position", original_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	anim.play("Attack")

	EnemySound_Manager.play_attack_sound(attack_sound, origin_node.global_position)

	await tween.finished
	anim.play("Walk")

	# Desativa a hitbox
	hitbox.monitoring = false
	hitbox.get_node("Attack Collider").disabled = true

	anim.position = Vector2.ZERO
	is_attacking = false
	set_process(true)



func _on_tween_finished():
	anim.position = Vector2.ZERO
	set_process(true)
	is_attacking = false
	

func _on_attack_hitbox_body_entered(body: CharacterBody2D) -> void:
	print("🎯 Detectado:", body.name, "Grupos:", body.get_groups())
	if body.is_in_group("player"):
	
		var energy_component = body.get_node_or_null("EnergyComponent")
		if energy_component:
			print("Chamando dano...")
			player.energy_component.take_damage(damage_percent)
			print("✅ Acertou player! Dano aplicado.")
		else:
			print("⚠ EnergyComponent não encontrado em", body)
