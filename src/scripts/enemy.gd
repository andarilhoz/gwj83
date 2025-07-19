class_name Enemy

extends CharacterBody2D


@onready var anim = $AnimatedSprite2D
@onready var attack: EnemyAttack = $EnemyAttack
@onready var movement_component: EnemyMovementComponent = $Enemy_movement_component
@export var absorbed_version: PackedScene #Cena do Inimigo dentro da Slime
var is_afraid: bool = false 

@export var min_speed: float = 100.0
@export var max_speed: float = 250.0
var speed = 0
@export var stop_distance: float = 150.0

var walk_timer: float = 0.0

@export var level = 1;
var player: CharacterBody2D
var initialized : bool = false

signal died

func _ready():
	speed = randf_range(min_speed, max_speed)
	var player = get_node("/root/Node2D/Player")  

	if player:
		player.player_died.connect(on_player_died)

func initialize(received_player: CharacterBody2D):
	attack.player = received_player
	attack.enemy_script = self
	player = received_player
	movement_component.start(self, speed, stop_distance) 
	initialized = true
	
	
func _physics_process(delta):
	if !player or attack.is_attacking:
		return
	
	is_afraid = player.level > level
	var to_player = movement_component.move_towards_player(player, delta, is_afraid)
	anim.flip_h = player.global_position.x < global_position.x
	move_and_slide()
	if velocity.length() > 0:
		anim.play("Walk")

	if velocity.length() < 1:
		if attack.can_attack():
			attack.attack(to_player)

func _process(delta):
	update_sprite_bounce(delta)

func update_sprite_bounce(delta):
	if velocity.length() > 1 and !attack.is_attacking:
		walk_timer += delta * 10
		anim.position.y = sin(walk_timer) * 1.5
		anim.rotation = sin(walk_timer) * deg_to_rad(3)
	else:
		anim.position.y = 0
		anim.rotation = 0
		walk_timer = 0

func die():
	died.emit()
	
func on_player_died():
	set_process(false)
	set_physics_process(false)
	
	if has_node("AttackSound"):
		$AttackSound.stop()
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("Idle")  # ou qualquer animação parada
