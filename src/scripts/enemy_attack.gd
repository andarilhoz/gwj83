extends Node

@export var bounce_distance: float = 6.0
@export var bounce_duration: float = 0.15
@export var cooldown: float = 1.0

var is_attacking = false
var attack_timer = 0.0
var anim: AnimatedSprite2D
var origin_node: Node2D  # onde a sprite está

func _ready():
	origin_node = get_parent()
	anim = origin_node.get_node("AnimatedSprite2D")  # ou ajuste o caminho se diferente

func _process(delta):
	if attack_timer > 0:
		attack_timer -= delta

func can_attack() -> bool:
	return attack_timer <= 0 and !is_attacking

func attack(direction: Vector2) -> void:
	if !can_attack():
		return

	is_attacking = true
	attack_timer = cooldown

	var original_position = anim.position
	var target_position = original_position + direction * bounce_distance

	set_process(false)

	var tween = create_tween()
	tween.tween_property(anim, "position", target_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim, "position", original_position, bounce_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.connect("finished", _on_tween_finished)


func _on_tween_finished():
	anim.position = Vector2.ZERO
	set_process(true)
	is_attacking = false
