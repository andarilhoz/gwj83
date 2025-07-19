class_name EnergyComponent
extends Node

@onready var progress_bar: TextureProgressBar = $"../../CanvasLayer/EnergyBar"

@export var initial_energy: float

signal zero_energy
signal energy_update(energy: float)

var current_energy: float
var max_energy: float = 100.0  # valor padrão, pode ser sobrescrito com set_max_energy()

func _ready():
	reset_energy()

func set_max_energy(value: float) -> void:
	max_energy = value
	progress_bar.max_value = max_energy

func add_energy(value: float):
	current_energy += value
	current_energy = min(current_energy, max_energy)
	progress_bar.value = current_energy
	energy_update.emit(current_energy)

func lose_energy(value: float): 
	current_energy -= value
	progress_bar.value = current_energy
	energy_update.emit(current_energy)
	if current_energy <= 0:
		zero_energy.emit()

func reset_energy():
	current_energy = initial_energy
	current_energy = min(current_energy, max_energy)
	progress_bar.value = current_energy
	energy_update.emit(current_energy)

func can_lose_energy(value: float) -> bool:
	return current_energy > value
	

func take_damage(percent: float):
	var damage = max_energy * percent
	current_energy -= damage
	current_energy = clamp(current_energy, 0, max_energy)
	print("Levou ", damage, " de dano. Energia atual: ", current_energy)
	flash_damage()
	if current_energy <= 0:
		zero_energy.emit()

func flash_damage():
	var sprite = $"../AnimatedSprite2D"
	for i in range(3):
		sprite.modulate = Color(1, 0.4, 0.4)  # vermelho claro
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)  # volta ao normal
		await get_tree().create_timer(0.1).timeout
