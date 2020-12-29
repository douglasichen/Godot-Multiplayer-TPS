extends Spatial

var local_player = null

func _process(_delta):
	if local_player != null:
		transform.origin = local_player.transform.origin
	pass

func _physics_process(_delta):
	pass
