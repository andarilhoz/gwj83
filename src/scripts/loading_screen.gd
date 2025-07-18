extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene_path)
	set_process(true) # garante que _process será chamado

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(new_scene)
		set_process(false) # desliga _process depois que trocou de cena
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Falha ao carregar a cena!")
		set_process(false)
