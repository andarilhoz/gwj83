class_name TileMovementComponent

extends Node2D

@export var tile_size: int = 16
@export var tilemap_path: NodePath
@export var move_duration: float = 0.1
@export var start_cell: Vector2 = Vector2i(24, 6)

var _tilemap: TileMapLayer
var moving: bool = false
var dashing: bool = false

func _ready():
	_tilemap = get_node(tilemap_path)

func start(entity: Object):
	entity.position = _tilemap.map_to_local(start_cell)

func move_in_direction(entity: Object, direction: Vector2):
	if moving or dashing:
		return
	
	moving = true
	var current_tile = _tilemap.local_to_map(entity.position)
	var next_tile = current_tile + Vector2i(direction)

	var tile_data = _tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		moving = false
		return

	var next_pos = _tilemap.map_to_local(next_tile)

	var tween := create_tween()
	tween.tween_property(entity, "position", next_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(entity, "_on_move_finished"))
	tween.connect("finished", Callable(self, "_on_move_finished"))

func dash_towards(entity: Object, blocks: int, direction: Vector2):
	if dashing:
		return
	
	if blocks < 1:
		dashing = false
		return
	
	var current_tile = _tilemap.local_to_map(entity.position)
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
	tween.connect("finished", Callable(entity, "_paint_tiles").bind(path_tiles))
	tween.connect("finished", Callable(entity, "_on_dash_finished"))
	tween.connect("finished", Callable(self, "_on_dash_finished"))

func _on_move_finished():
	moving = false

func _on_dash_finished():
	dashing = false
