class_name EnemyInside
extends Node2D

@export var rigidbody: RigidBody2D
@export var energy: float
@onready var sprite = $RigidBody2D/Sprite2D


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
