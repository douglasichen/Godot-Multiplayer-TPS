extends Listener

var local_player

func _process(_delta):
	var game = get_node("/root/Game")
	for i in game.get_children():
		if i.get("tag") != null:
			if i.tag == "player":
				if i.is_network_master():
					local_player = i
					break
	if local_player != null:
		transform.origin = local_player.transform.origin
	pass