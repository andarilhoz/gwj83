class_name EnergyComponent

extends Node

@onready var progress_bar: TextureProgressBar = $"../../CanvasLayer/EnergyBar"
@export var initial_energy: float

signal zero_energy
signal energy_update(energy: float)

var current_energy: float

func _ready():
	current_energy = initial_energy
	progress_bar.value = current_energy

func add_energy(value: float):
	current_energy += value
	progress_bar.value = current_energy
	energy_update.emit(current_energy)

func lose_energy(value: float): 
	current_energy -= value
	progress_bar.value = current_energy
	energy_update.emit(current_energy)
	if current_energy <= 0:
		zero_energy.emit()

func can_lose_energy(value: float) -> bool:
	return current_energy > value
