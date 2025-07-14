extends CharacterBody2D

@export var tile_movement_component: TileMovementComponent
@export var energy_component: EnergyComponent
@export var tilemap_slime: NodePath
@export var walk_loss_energy: float
@export var dash_loss_energy: float

var _tilemap_slime: TileMapDual
var last_direction = Vector2.ZERO

var dashing: bool = false
var level: int = 1
var dash_amount: int = 3

var target_position: Vector2 = Vector2.ZERO
var has_target_position: bool = false
@export var move_speed: float 
@export var dash_speed: float

@onready var area2d: Area2D = $Area2D
var painted_coords = Vector2i(2, 1)

var current_speed: float = 0.0

func _ready():
	current_speed = move_speed
	_tilemap_slime = get_node(tilemap_slime)
	tile_movement_component.start(self, level)
	paint_current_tile(level)

func _physics_process(delta):
	if has_target_position:
		var direction = (target_position - position).normalized()
		var distance = position.distance_to(target_position)

		if distance < 10.0:
			if dashing:
				_on_dash_finished()
			position = target_position
			velocity = Vector2.ZERO
			has_target_position = false
		else:
			velocity = direction * current_speed

	else:
		if dashing:
			_on_dash_finished()
		velocity = Vector2.ZERO

	move_and_slide()
	paint_current_tile(level)

func _process(delta):
	if dashing:
		return

	var current_direction = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		current_direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		current_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		current_direction = Vector2.LEFT
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("move_right"):
		current_direction = Vector2.RIGHT
		$AnimatedSprite2D.flip_h = true

	if current_direction != Vector2.ZERO:
		move_towards(current_direction)
		if $AnimatedSprite2D.animation != "Walk" && !($AnimatedSprite2D.animation == "Dash_Finish" && $AnimatedSprite2D.is_playing()):
			$AnimatedSprite2D.play("Walk")
	else:
		if $AnimatedSprite2D.animation != "Idle" && !($AnimatedSprite2D.animation == "Dash_Finish" && $AnimatedSprite2D.is_playing()):
			$AnimatedSprite2D.play("Idle")

	if Input.is_action_just_pressed("attack"):
		dash()

func move_towards(direction: Vector2):
	if has_target_position:
		return
	
	var has_slime = tile_movement_component.has_slime_in_direction(direction, level)
	var can_spend = energy_component.can_lose_energy(walk_loss_energy)

	if !has_slime and !can_spend:
		return

	last_direction = direction
	tile_movement_component.move_in_direction(self, direction, level)

func dash():
	if !energy_component.can_lose_energy(dash_loss_energy):
		return

	dashing = true
	current_speed = dash_speed  # aumenta a velocidade
	energy_component.lose_energy(dash_loss_energy)
	tile_movement_component.dash_towards(self, dash_amount, last_direction, level)
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if !body.is_in_group("enemy"):
			continue
		var enemy = body as Enemy
		
		if enemy.level == level:
			enemy.die()
			_spawn_enemy_inside()
	$AnimatedSprite2D.play("Dash")


func _on_painted_floor():
	energy_component.lose_energy(walk_loss_energy)

func _on_dash_finished():
	$AnimatedSprite2D.play("Dash_Finish")
	dashing = false
	current_speed = move_speed 
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("enemy"):
		return

	var enemy = body as Enemy

	if enemy.level < level:
		enemy.die()
		_spawn_enemy_inside()
		$AnimatedSprite2D.play("After_Eating")
	elif enemy.level == level and dashing:
		enemy.die()
		_spawn_enemy_inside()
		$AnimatedSprite2D.play("After_Eating")

func _spawn_enemy_inside():
	var scene = preload("res://src/scenes/EnemyInsideSlime.tscn")
	var enemy_instance = scene.instantiate()

	$InternalPhysicsBodies.add_child(enemy_instance)

	# Raio de spawn interno
	var spawn_radius := 20.0  # 🔧 Ajuste conforme o tamanho do slime

	# Posição aleatória dentro do círculo
	var angle = randf() * TAU
	var distance = randf() * spawn_radius
	var offset = Vector2(cos(angle), sin(angle)) * distance
	enemy_instance.position = offset

	# Rotação aleatória (em radianos)
	enemy_instance.rotation = randf() * TAU

	# Configura o joint
	var joint = enemy_instance.get_node("DampedSpringJoint2D")
	joint.node_b = get_path()  # o player/slime


func paint_current_tile(size: int):
	if tile_movement_component.has_slime_in_cell(size):
		return
		
	var cell = _tilemap_slime.local_to_map(global_position)
	_tilemap_slime.set_cell(cell, 0, painted_coords)


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Dash_Finish":
		pass # Replace with function body.
