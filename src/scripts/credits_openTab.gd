extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_credits_andre_pressed() -> void:
	OS.shell_open("https://www.andrevargasgd.com")


func _on_credits_magno_pressed() -> void:
	OS.shell_open("https://www.linkedin.com/in/magnogou/")
	



func _on_gus_credits_pressed() -> void:
	OS.shell_open("https://www.linkedin.com/in/gustavocgoncalves/")
	



func _on_cintia_credits_pressed() -> void:
	OS.shell_open("https://www.artstation.com/cintxa")
