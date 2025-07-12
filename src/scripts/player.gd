extends CharacterBody2D

@export var tilemap_slime: NodePath
@export var tile_movement_component: TileMovementComponent

var _tilemap_slime: TileMapDual
var _move_timer: float = 0.0
var painted_coords = Vector2i(2, 1)

func _ready():
	_tilemap_slime = get_node(tilemap_slime)
	tile_movement_component.start(self)
	paint_current_tile()

func _process(delta):
	_move_timer -= delta
	if _move_timer > 0:
		return

	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		input_dir = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input_dir = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input_dir = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input_dir = Vector2.RIGHT

	if input_dir != Vector2.ZERO:
		tile_movement_component.move_in_direction(self, input_dir)


func paint_current_tile():
	var cell = _tilemap_slime.local_to_map(position)
	_tilemap_slime.set_cell(cell, 0, painted_coords)

func _on_move_finished():
	paint_current_tile()
