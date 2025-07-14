extends Node2D

@export var rigidbody: RigidBody2D

func _physics_process(delta):
	if randi() % 60 == 0:
		rigidbody.apply_impulse(Vector2(randf_range(-20, 20), randf_range(-20, 20)))


func _on_timer_timeout() -> void:
	queue_free()
