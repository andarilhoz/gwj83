extends Node
class_name EnemySoundManager

var last_attack_time := 0.0
var cooldown := 0.2

func play_attack_sound(stream: AudioStream, position: Vector2):
	if stream == null:
		return
	
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time >= cooldown:
		last_attack_time = now
		
		var player := AudioStreamPlayer2D.new()
		player.stream = stream
		player.position = position
		get_tree().current_scene.add_child(player)
		player.play()
		player.connect("finished", player.queue_free)
