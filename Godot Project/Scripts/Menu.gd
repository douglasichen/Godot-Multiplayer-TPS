extends Node

func _on_Host_pressed():
	get_tree().change_scene("res://Scenes/Host.tscn")
func _on_Connect_pressed():
	get_tree().change_scene("res://Scenes/Connect.tscn")