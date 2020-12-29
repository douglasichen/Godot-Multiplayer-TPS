extends Area

export var bullet_speed = 10.0

var cr_time = 300

func _ready():
	var shot_sound = preload("res://Prefabs/prefab_shot_sound.tscn").instance()
	shot_sound.transform.origin = transform.origin
	var sound_clutter = get_node("/root/Game/sound_clutter")
	sound_clutter.add_child(shot_sound)
	pass

func _process(delta):
	var parent = get_node("/root/Game/bullets")
	if cr_time > 0: cr_time -= 1
	else: parent.remove_child(self)
	Move(delta)
	var game = get_node("/root/Game")
	
	var colliding_with = get_overlapping_bodies()
	for i in colliding_with:
		if i.get("tag") != null:
			if i.tag == "player":
				if is_network_master():
					send_kill_player_to_all_clients(i)
					game.remove_child(i)
					game.Respawn(int(i.name))
					parent.remove_child(self)
		else:
			parent.remove_child(self)
	pass

func Move(delta):
	translate_object_local(Vector3(0,0,-bullet_speed * delta))
	pass

func send_kill_player_to_all_clients(killed_player):
	var local_id = get_tree().get_network_unique_id()
	for i in Network.data:
		if i.id != local_id:
			rpc_id(i.id, "_send_kill_player", killed_player)
