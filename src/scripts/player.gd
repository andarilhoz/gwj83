extends CharacterBody2D

@export var tilemap_slime: NodePath
@export var tile_movement_component: TileMovementComponent

var _tilemap_slime: TileMapDual
var _move_timer: float = 0.0
var painted_coords = Vector2i(2, 1)

var last_direction = Vector2.ZERO

var dashing: bool = false

func _ready():
	_tilemap_slime = get_node(tilemap_slime)
	tile_movement_component.start(self)
	paint_current_tile()

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
		last_direction = current_direction
		tile_movement_component.move_in_direction(self, current_direction)
	
	if Input.is_action_just_pressed("attack"):
		dash()


func dash():
	dashing = true
	tile_movement_component.dash_towards(self, 3, last_direction)

func paint_current_tile():
	var cell = _tilemap_slime.local_to_map(position)
	_tilemap_slime.set_cell(cell, 0, painted_coords)

func _paint_tiles(cells):
	for cell in cells:
		_tilemap_slime.set_cell(cell, 0, painted_coords)

func _on_move_finished():
	paint_current_tile()

func _on_dash_finished():
	dashing = false
