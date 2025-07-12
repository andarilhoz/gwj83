class_name TileMovementComponent

extends Node2D

@export var tilemap_slime: NodePath
@export var tile_size: int = 16
@export var tilemap_path: NodePath
@export var move_duration: float = 0.1
@export var start_cell: Vector2 = Vector2i(24, 6)

var _tilemap_slime: TileMapDual
var _tilemap: TileMapLayer
var moving: bool = false
var dashing: bool = false
var painted_coords = Vector2i(2, 1)

signal painted_floor

func _ready():
	_tilemap_slime = get_node(tilemap_slime)
	_tilemap = get_node(tilemap_path)
	
func start(entity: Object):
	entity.position = _tilemap.map_to_local(start_cell)
	paint_current_tile()
	
func has_slime_in_direction(direction: Vector2) -> bool:
	var current_tile = _tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)
	var slime_tile_data = _tilemap_slime.get_cell_tile_data(next_tile)
	return slime_tile_data != null

func has_slime_in_cell() -> bool:
	var current_tile = _tilemap.local_to_map(global_position)
	var slime_tile_data = _tilemap_slime.get_cell_tile_data(current_tile)
	return slime_tile_data != null
	
func move_in_direction(entity: Object, direction: Vector2):
	if moving or dashing:
		return
	
	moving = true
	var current_tile = _tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)

	var tile_data = _tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		moving = false
		return

	var next_pos = _tilemap.map_to_local(next_tile)

	var tween := create_tween()
	tween.tween_property(entity, "position", next_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_move_finished"))

func dash_towards(entity: Object, blocks: int, direction: Vector2):
	if dashing:
		return
	
	if blocks < 1:
		dashing = false
		return
	
	var current_tile = _tilemap.local_to_map(global_position)
	var next_tile = current_tile + (Vector2i(direction) * blocks)

	var tile_data = _tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		dash_towards(entity, blocks - 1, direction)
		return

	var path_tiles: Array[Vector2i] = []
	for i in blocks:
		var step_tile = current_tile + (Vector2i(direction) * (i + 1))
		path_tiles.append(step_tile)

	dashing = true

	var next_pos = _tilemap.map_to_local(next_tile)

	var tween := create_tween()
	tween.tween_property(entity, "position", next_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_paint_tiles").bind(path_tiles))
	tween.connect("finished", Callable(self, "_on_dash_finished"))

func _on_move_finished():
	paint_current_tile()
	moving = false

func _on_dash_finished():
	dashing = false

func paint_current_tile():
	if has_slime_in_cell():
		return
		
	painted_floor.emit()
	var cell = _tilemap_slime.local_to_map(global_position)
	_tilemap_slime.set_cell(cell, 0, painted_coords)


func _paint_tiles(cells):
	for cell in cells:
		_tilemap_slime.set_cell(cell, 0, painted_coords)
