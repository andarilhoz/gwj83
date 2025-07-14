class_name TileMovementComponent

extends Node2D

@export var tilemap_slime: NodePath
@export var tile_size: int = 16
@export var tilemap_path_small: NodePath
@export var tilemap_path_medium: NodePath
@export var tilemap_path_big: NodePath
@export var move_duration: float = 0.1
@export var start_cell: Vector2 = Vector2i(24, 6)

var _tilemap_slime: TileMapDual
var _tilemap_small: TileMapLayer
var _tilemap_medium: TileMapLayer
var _tilemap_big: TileMapLayer
var moving: bool = false
var dashing: bool = false
var painted_coords = Vector2i(2, 1)

signal painted_floor

func _ready():
	_tilemap_slime = get_node(tilemap_slime)
	_tilemap_small = get_node(tilemap_path_small)
	_tilemap_medium = get_node(tilemap_path_medium)
	_tilemap_big = get_node(tilemap_path_big)
	
func start(entity: Object, size: int):
	entity.position = _tilemap_small.map_to_local(start_cell)
	paint_current_tile(size)
	
func has_slime_in_direction(direction: Vector2, size: int) -> bool:
	var tilemap = get_tilemap_by_size(size)
	var current_tile = tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)
	var slime_tile_data = _tilemap_slime.get_cell_tile_data(next_tile)
	return slime_tile_data != null

func has_slime_in_cell(size: int) -> bool:
	var tilemap = get_tilemap_by_size(size)
	var current_tile = tilemap.local_to_map(global_position)
	var slime_tile_data = _tilemap_slime.get_cell_tile_data(current_tile)
	return slime_tile_data != null
	
func move_in_direction(entity: Object, direction: Vector2, size: int):
	if moving or dashing:
		return
	
	var tilemap = get_tilemap_by_size(size)
	
	moving = true
	var current_tile = tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)

	var tile_data = tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		moving = false
		return

	var next_pos = tilemap.map_to_local(next_tile)

	var tween := create_tween()
	tween.tween_property(entity, "position", next_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_move_finished").bind(size))

func dash_towards(entity: Object, blocks: int, direction: Vector2, size: int):
	if dashing:
		return
	
	if blocks < 1:
		entity.call("_on_dash_finished")
		dashing = false
		return
	
	var tilemap = get_tilemap_by_size(size)
	
	var current_tile = tilemap.local_to_map(global_position)
	var next_tile = current_tile + (Vector2i(direction) * blocks)

	var tile_data = tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		dash_towards(entity, blocks - 1, direction, size)
		return

	var path_tiles: Array[Vector2i] = []
	for i in blocks:
		var step_tile = current_tile + (Vector2i(direction) * (i + 1))
		path_tiles.append(step_tile)

	dashing = true

	var next_pos = tilemap.map_to_local(next_tile)

	var tween := create_tween()
	tween.tween_property(entity, "position", next_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_paint_tiles").bind(path_tiles))
	tween.connect("finished", Callable(self, "_on_dash_finished"))
	tween.connect("finished", Callable(entity, "_on_dash_finished"))

func _on_move_finished(size: int):
	paint_current_tile(size)
	moving = false

func _on_dash_finished():
	dashing = false

func paint_current_tile(size: int):
	if has_slime_in_cell(size):
		return
		
	painted_floor.emit()
	var cell = _tilemap_slime.local_to_map(global_position)
	_tilemap_slime.set_cell(cell, 0, painted_coords)


func _paint_tiles(cells):
	for cell in cells:
		_tilemap_slime.set_cell(cell, 0, painted_coords)

func get_tilemap_by_size(size: int):
	match size:
		1:
			return _tilemap_small
		2:
			return _tilemap_medium
		3: 
			return _tilemap_big
