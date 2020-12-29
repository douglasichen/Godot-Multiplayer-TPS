extends Node

var ip = "127.0.0.1"

func _on_Ip_changed(input):
	ip = input

func _on_Connect_pressed():
	Network._connect_to_server(ip)

func _process(_delta):
	var key_esc = Input.is_action_just_pressed("esc")
	if key_esc:
		get_tree().change_scene("res://Scenes/Menu.tscn")
	pass