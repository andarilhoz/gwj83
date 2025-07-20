class_name EnemyInside
extends Node2D

@export var rigidbody: RigidBody2D
@export var level: int
@onready var sprite = $RigidBody2D/Sprite2D

enum type {
	enemy,consumable
}

enum enemy_type {
	Goblin,
	Orc,
	Dragon
}

@export var self_type: type
@export var self_enemy_type: enemy_type

var player_level: int
var energy: float

func initialize():
	if self_type==type.enemy:
		var current_stats = GameConfigLoader.getLevelStats(player_level)
		match self_enemy_type:
			enemy_type.Goblin: energy = current_stats.goblin_energy
			enemy_type.Orc: energy = current_stats.orc_energy
			enemy_type.Dragon: energy = current_stats.dragon_energy
			_: energy = 0
	else:
		match level:
			1: energy = GameConfigLoader.config.consumable_level_1
			2: energy = GameConfigLoader.config.consumable_level_2
			3: energy = GameConfigLoader.config.consumable_level_3
			_: energy = GameConfigLoader.config.consumable_level_1

func _ready():
	apply_slime_tint()

func apply_slime_tint():
	sprite.modulate = Color(0.6, 1.0, 0.6, 0.3)  # verde claro

func _physics_process(delta):
	if randi() % 60 == 0:
		rigidbody.apply_impulse(Vector2(randf_range(-20, 20), randf_range(-20, 20)))

func absorbe_energy(absorbed: float) -> float:
	var excess_absorbtion = absorbed - energy
	energy -= absorbed		
	return excess_absorbtion


func dissolve_complete():
	queue_free()
