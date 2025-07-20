class_name EnergyComponent
extends Node

@onready var progress_bar: TextureProgressBar = $"../../CanvasLayer/EnergyBar"

@onready var animated_death: AnimatedSprite2D = $"../../CanvasLayer/AnimatedDeath"
@onready var animated_up: AnimatedSprite2D = $"../../CanvasLayer/AnimatedUp"

@export var initial_energy: float

signal zero_energy
signal energy_update(energy: float)

var current_energy: float
var max_energy: float = 100.0  # valor padrão, pode ser sobrescrito com set_max_energy()

var is_invulnerable: bool = false

@export_range(0, 100, .1)
var magnitude: float = 10

var is_shaking: bool = false
var shake_amt: Vector2 = Vector2.ZERO

@export var shake_timer: Timer

var shake_cam: PhantomCamera2D

func set_max_energy(value: float) -> void:
	max_energy = value
	progress_bar.max_value = max_energy

func add_energy(value: float):
	current_energy += value
	current_energy = min(current_energy, max_energy)
	progress_bar.value = current_energy
	energy_update.emit(current_energy)
	update_anim()

func lose_energy(value: float): 
	current_energy -= value
	progress_bar.value = current_energy
	energy_update.emit(current_energy)
	update_anim()
	if current_energy <= 0:
		zero_energy.emit()

func reset_energy(initial_energy):
	current_energy = initial_energy
	current_energy = min(current_energy, max_energy)
	progress_bar.value = current_energy
	energy_update.emit(current_energy)

func can_lose_energy(value: float) -> bool:
	return current_energy > value
	

func take_damage(percent: float, player: PlayerScript):
	if is_invulnerable:
		return
		
	is_invulnerable = true
	var damage = max_energy * percent
	print("Levou ", damage, " de dano. Energia atual: ", current_energy)
	flash_damage()
	lose_energy(damage)
 	

func flash_damage():
	var sprite = $"../AnimatedSprite2D"
	for i in range(3):
		sprite.modulate = Color(1, 0.4, 0.4)  # vermelho claro
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)  # volta ao normal
		await get_tree().create_timer(0.1).timeout
	
	is_invulnerable = false

func update_anim():
	var normalized: float = (progress_bar.value - progress_bar.min_value) / (progress_bar.max_value - progress_bar.min_value)

	if normalized < 0.1:
		animated_death.show()
		animated_death.play()
	elif normalized >= 0.9:
		animated_up.show()
		animated_up.play()
	else:
		animated_death.hide()
		animated_up.hide()
		
