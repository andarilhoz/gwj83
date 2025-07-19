class_name TileMovementComponent
extends Node2D

@export var tile_size: int = 16
@export var tilemap_path_small: NodePath
@export var tilemap_path_medium: NodePath
@export var tilemap_path_big: NodePath
@export var move_duration: float = 0.2
@export var start_cell: Vector2 = Vector2i(0, 0)

var _tilemap_slime_1: TileMapDual
var _tilemap_slime_2: TileMapDual
var _tilemap_slime_3: TileMapDual

var _tilemap_small: TileMapLayer
var _tilemap_medium: TileMapLayer
var _tilemap_big: TileMapLayer


var initialized: bool = false

func _ready():	
	_tilemap_small = get_node(tilemap_path_small)
	_tilemap_medium = get_node(tilemap_path_medium)
	_tilemap_big = get_node(tilemap_path_big)
	
func start(entity: Object, size: int, slimap_1: TileMapDual, slimap_2: TileMapDual, slimap_3: TileMapDual ):
	entity.position = _tilemap_small.map_to_local(start_cell)
	_tilemap_slime_1 = slimap_1
	_tilemap_slime_2 = slimap_2
	_tilemap_slime_3 = slimap_3
	initialized = true

func has_slime_in_direction(direction: Vector2, size: int) -> bool:
	if !initialized:
		return false
	var tilemap = get_tilemap_by_size(size)
	var current_tile = tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)
	var slime_tile_data = get_tilemap_slime_by_size(size).get_cell_tile_data(next_tile)
	return slime_tile_data != null

func has_slime_in_cell(size: int) -> bool:
	if !initialized:
		return false
	var tilemap = get_tilemap_by_size(size)
	var current_tile = tilemap.local_to_map(global_position)
	var slimap = get_tilemap_slime_by_size(size)
	var slime_tile_data = slimap.get_cell_tile_data(current_tile)
	return slime_tile_data != null
	
func move_in_direction(entity: CharacterBody2D, direction: Vector2, size: int):
	if entity.has_target_position:
		return
	
	var tilemap = get_tilemap_by_size(size)

	var current_tile = tilemap.local_to_map(global_position)
	var next_tile = current_tile + Vector2i(direction)

	var tile_data = tilemap.get_cell_tile_data(next_tile)
	if tile_data == null:
		return

	var next_pos = tilemap.map_to_local(next_tile)

	entity.target_position = next_pos
	entity.has_target_position = true

func dash_towards(entity: CharacterBody2D, blocks: int, direction: Vector2, size: int):
	if blocks < 1:
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

	var next_pos = tilemap.map_to_local(next_tile)

	entity.target_position = next_pos
	entity.has_target_position = true


func get_tilemap_by_size(size: int):
	match size:
		1: return _tilemap_small
		2: return _tilemap_medium
		3: return _tilemap_big

func get_tilemap_slime_by_size(size: int) -> TileMapDual:
	match size:
		1: return _tilemap_slime_1
		2: return _tilemap_slime_2
		3: return _tilemap_slime_3
	return _tilemap_slime_1
