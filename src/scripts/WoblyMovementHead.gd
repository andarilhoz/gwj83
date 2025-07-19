extends Control

@export var base_angle_range_deg := 10.0
@export var base_swing_range := 1.0
@export var base_speed := 2.0

var original_rotation: float
var original_position: Vector2

var angle_range_deg := 0.0
var swing_range := 0.0
var speed := 0.0
var offset := 0.0

func _ready():
	original_rotation = rotation
	original_position = position

	# Randomiza valores com pequenas variações
	angle_range_deg = base_angle_range_deg + randf_range(-3.0, 3.0)
	swing_range = base_swing_range + randf_range(-2.0, 2.0)
	speed = base_speed + randf_range(-0.3, 0.3)

	# Pequeno offset de tempo pra cada objeto começar diferente
	offset = randf() * PI * 2
func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0 + offset
	var sine = sin(t * speed)

	rotation = original_rotation + deg_to_rad(sine * angle_range_deg)
	position.y = original_position.y + cos(t * speed) * swing_range
