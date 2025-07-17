extends Control



func _on_volume_value_changed(value: float) -> void:
	var normalized = clamp(value / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(normalized))


func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2(1600,900))
		2:
			DisplayServer.window_set_size(Vector2(1280,720))

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
