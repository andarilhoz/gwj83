extends CharacterBody2D

@export var tile_movement_component: TileMovementComponent
@export var energy_component: EnergyComponent

@export var walk_loss_energy: float
@export var dash_loss_energy: float

var _move_timer: float = 0.0
var last_direction = Vector2.ZERO

var dashing: bool = false
var level: int = 1

func _ready():
	tile_movement_component.start(self, level)
	tile_movement_component.painted_floor.connect(Callable(self, "_on_painted_floor"))

func _process(delta):
	_move_timer -= delta
	if _move_timer > 0:
		return

	var current_direction = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		current_direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		current_direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		current_direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		current_direction = Vector2.RIGHT
	
	if current_direction != Vector2.ZERO:
		move_towards(current_direction)
	
	if Input.is_action_just_pressed("attack"):
		dash()
	
func move_towards(direction: Vector2):
	var has_slime = tile_movement_component.has_slime_in_direction(direction, level)
	var can_spend = energy_component.can_lose_energy(walk_loss_energy)
	
	if(!has_slime && !can_spend):
		return
		
	last_direction = direction
	tile_movement_component.move_in_direction(self, direction, level)

func dash():
	if !energy_component.can_lose_energy(dash_loss_energy):
		return
	
	dashing = true
	energy_component.lose_energy(dash_loss_energy)
	tile_movement_component.dash_towards(self, 3, last_direction, level)

func _on_painted_floor():
	energy_component.lose_energy(walk_loss_energy)

func _on_dash_finished():
	dashing = false
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("enemy"):
		return
	
	var enemy = body as Enemy
	
	if enemy.level < level:
		enemy.die()
	elif enemy.level == level and dashing:
		enemy.die()
		
	
	
	
