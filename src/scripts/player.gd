class_name PlayerScript
extends CharacterBody2D

@export var tile_movement_component: TileMovementComponent
@export var energy_component: EnergyComponent
@export var tilemap_slime_level_1: NodePath
@export var tilemap_slime_level_2: NodePath
@export var tilemap_slime_level_3: NodePath

@export var phantom_camera_level_1 : PhantomCamera2D
@export var phantom_camera_level_2 : PhantomCamera2D
@export var phantom_camera_level_3 : PhantomCamera2D

var _tilemap_slime_level_1: TileMapDual
var _tilemap_slime_level_2: TileMapDual
var _tilemap_slime_level_3: TileMapDual
var last_direction = Vector2.ZERO

var dashing: bool = false
var level: int = 1
var dash_amount: int = 3

var target_position: Vector2 = Vector2.ZERO
var has_target_position: bool = false
var current_stats: LevelStats

@onready var area2d: Area2D = $Area2D
var painted_coords = Vector2i(2, 1)

var current_speed: float = 0.0

var absorbed_enemies : Array[EnemyInside] = []

var is_dead: bool = false
signal player_died
signal victory
var final_form_announced := false


func _ready():
	_tilemap_slime_level_1 = get_node(tilemap_slime_level_1)
	_tilemap_slime_level_2 = get_node(tilemap_slime_level_2)
	_tilemap_slime_level_3 = get_node(tilemap_slime_level_3)
	energy_component.zero_energy.connect(die)
	
	update_stats_for_level()
	
	tile_movement_component.start(self, level, _tilemap_slime_level_1, _tilemap_slime_level_2, _tilemap_slime_level_3)
	update_size(GameConfigLoader.config.player_initial_energy)
	energy_component.energy_update.connect(update_size)
	phantom_camera_level_1.priority = 1
	phantom_camera_level_2.priority = 0
	phantom_camera_level_3.priority = 0
	paint_current_tile(level)
	update_stats_for_level()

func get_tilemap_by_size() -> TileMapDual:
	match level:
		1: return _tilemap_slime_level_1
		2: return _tilemap_slime_level_2
		3: return _tilemap_slime_level_3
	return _tilemap_slime_level_1
	
func update_size(percentage: float):
	if percentage >= current_stats.max_energy and level < 3:
		evolve()
		return
	
	var update_scale = percentage / 100
	update_scale = GameConfigLoader.config.min_player_scale if update_scale < GameConfigLoader.config.min_player_scale else update_scale
	update_scale+=level
	scale = Vector2(update_scale, update_scale)
	
	if not final_form_announced and level == 3 and percentage >= current_stats.max_energy:
		final_form_announced = true
		victory.emit()

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
	var can_spend = energy_component.can_lose_energy(current_stats.walk_loss_energy)

	if !has_slime and !can_spend:
		return
	last_direction = direction
	tile_movement_component.move_in_direction(self, direction, level)
	
	if has_target_position and !has_slime and can_spend:
		energy_component.lose_energy(current_stats.walk_loss_energy)


func evolve():
	update_stats_for_level()
	var tilemap = get_tilemap_by_size()
	tilemap.clear()
	level += 1
	energy_component.reset_energy()
	if level == 2:
		phantom_camera_level_2.priority = 2
	elif level == 3:
		phantom_camera_level_3.priority = 3
	

func dash():
	if !absorbed_enemies.is_empty():
		return
		
	if !energy_component.can_lose_energy(current_stats.dash_loss_energy):
		return

	dashing = true
	current_speed = current_stats.dash_speed  # aumenta a velocidade
	energy_component.lose_energy(current_stats.dash_loss_energy)
	tile_movement_component.dash_towards(self, dash_amount, last_direction, level)
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if !body.is_in_group("enemy"):
			continue
		var enemy = body as Enemy
		
		if enemy.level == level:
			enemy.die()
			_spawn_enemy_inside(enemy.absorbed_version)
	$AnimatedSprite2D.play("Dash")


func _on_painted_floor():
	energy_component.lose_energy(current_stats.walk_loss_energy)

func _on_dash_finished():
	$AnimatedSprite2D.play("Dash_Finish")
	dashing = false
	current_speed = current_stats.move_speed 
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("enemy"):
		return

	var enemy = body as Enemy

	if enemy.level < level || (enemy.level == level and dashing):
		kill_enemy(enemy)

func kill_enemy(enemy: Enemy):
	enemy.die()
	_spawn_enemy_inside(enemy.absorbed_version)
	$AnimatedSprite2D.play("After_Eating")

func _spawn_enemy_inside(absorbed_scene: PackedScene):
	var enemy_instance = absorbed_scene.instantiate()
	absorbed_enemies.append(enemy_instance as EnemyInside)
	$InternalPhysicsBodies.add_child(enemy_instance)

	# Posição aleatória dentro de um círculo interno
	var spawn_radius := 20.0
	var angle = randf() * TAU
	var distance = randf() * spawn_radius
	var offset = Vector2(cos(angle), sin(angle)) * distance
	enemy_instance.position = offset

	# Rotação aleatória
	enemy_instance.rotation = randf() * TAU

	# Conecta o inimigo à física do slime via joint
	var joint = enemy_instance.get_node("DampedSpringJoint2D")
	joint.node_b = get_path()


func paint_current_tile(size: int):
	if tile_movement_component.has_slime_in_cell(size):
		return
	
	var tilemap = get_tilemap_by_size()
	var cell = tilemap.local_to_map(global_position)
	tilemap.set_cell(cell, 0, painted_coords)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Dash_Finish":
		pass # Replace with function body.

func _on_digestao_timeout() -> void:
	process_food(current_stats.process_food_by_seconds)

func process_food(process_food_value: float):
	if absorbed_enemies.is_empty():
		return
		
	var first_food = absorbed_enemies[0]
	var returned_absorption = first_food.absorbe_energy(process_food_value)
	if returned_absorption > 0:
		var energy_absorbed = process_food_value - returned_absorption
		energy_component.add_energy(energy_absorbed)
		absorbed_enemies.pop_front()
		first_food.dissolve_complete()
		process_food(returned_absorption)
	else:
		energy_component.add_energy(process_food_value)
	
func update_stats_for_level():
	match level:
		1: current_stats = GameConfigLoader.config.level_1_stats
		2: current_stats = GameConfigLoader.config.level_2_stats
		3: current_stats = GameConfigLoader.config.level_3_stats
		_: current_stats = GameConfigLoader.config.level_1_stats

	current_speed = current_stats.move_speed
	energy_component.set_max_energy(current_stats.max_energy)


func die():
	if is_dead:
		return
	is_dead = true
	player_died.emit()

	remove_from_group("player") #remover pros inimigos calarem a boca
	print("Jogador morreu!")

	# Cancela qualquer movimento
	has_target_position = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)

	# Toca animação de morte
	$AnimatedSprite2D.play("Death")

	# Opcional: para o tempo do jogo após a animação terminar
	await $AnimatedSprite2D.animation_finished
	get_tree().paused = true
