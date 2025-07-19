extends Control

@onready var menu_container = $VBoxContainer
@onready var settings_panel = $Settings
@onready var credits_panel = $Credits
@onready var instructions_panel = $Instructions



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/loading_screen.tscn")



func _on_options_pressed() -> void:
	menu_container.visible = false
	settings_panel.visible = true


func _on_exit_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void: # RETURN DO SETTINGS
	settings_panel.visible = false
	menu_container.visible = true


func _on_return_Credits_pressed() -> void:
	credits_panel.visible = false
	menu_container.visible = true


func _on_credits_pressed() -> void:
	credits_panel.visible = true
	menu_container.visible = false


func _on_instructions_pressed() -> void:
	instructions_panel.visible = true
	menu_container.visible = false


func _on_instructions_return_pressed() -> void:
	instructions_panel.visible = false
	menu_container.visible = true
