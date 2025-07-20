extends Control
@onready var pause_menu = $PauseMenu
var is_paused = false

@onready var Win_menu =  $Win_Screen
@onready var defeat_menu = $Defeat_Screen
@onready var player = $Player  # ou via grupo
@onready var player_canvas = $"../CanvasLayer"

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player = players[0]
	player.player_died.connect(_on_player_died)
	player.victory.connect(_on_player_victory)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var players = get_tree().get_nodes_in_group("player")
		if players.is_empty():
			return

		var player = players[0]
		if player.is_dead:
			return  # não pausa se o player morreu

		toggle_pause()


func _process(delta: float) -> void:
	pass


func _on_try_again_pressed() -> void:
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://src/scenes/loading_screen.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://src/scenes/Main_Menu.tscn")


func _on_resume_pressed() -> void:
	toggle_pause()
	
	
func toggle_pause():
	is_paused = !is_paused 
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	player_canvas.visible = !is_paused

	
func _on_player_died():
	player_canvas.visible = false
	defeat_menu.visible = true
	get_tree().paused = true
	
func _on_player_victory():
	player_canvas.visible = false
	Win_menu.visible = true
	get_tree().paused = true
