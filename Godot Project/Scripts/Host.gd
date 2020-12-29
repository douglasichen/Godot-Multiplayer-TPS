extends Node
func _on_Host_pressed():
	Network._create_server()
	
func _process(_delta):
	var key_esc = Input.is_action_just_pressed("esc")
	if key_esc:
		get_tree().change_scene("res://Scenes/Menu.tscn")
	pass
