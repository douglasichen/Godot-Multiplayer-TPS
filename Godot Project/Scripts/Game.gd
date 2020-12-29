extends Node

var spawn_cooldown = 100
var spawn_time = spawn_cooldown
var respawn = false
var respawn_id

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_network_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_server_disconnected')
	# spawn players that were in the game previously
	var local_id = get_tree().get_network_unique_id()
	for i in Network.data:
		if i.id != local_id:
			var prefab_player = preload("res://Prefabs/prefab_Player.tscn").instance()	# load player
			prefab_player.name = str(i.id)
			prefab_player.transform.origin = i.pos
			# prefab_player_non_local.set_network_master(i.id)
			add_child(prefab_player)
	spawn_client_player()
	pass

func spawn_client_player():
	# spawn self
	var local_id = get_tree().get_network_unique_id()
	var prefab_player = preload("res://Prefabs/prefab_Player.tscn").instance()	# load player
	# var prefab_camera = preload("res://Prefabs/prefab_camera.tscn").instance()	# load camera
	# prefab_player.add_child(prefab_camera)									# add the camera to the player object
	prefab_player.set_network_master(local_id)
	prefab_player.name = str(local_id)
	prefab_player.transform.origin = Network.self_data.spawn_pos
	
	
	var camera = preload("res://Prefabs/prefab_camera.tscn").instance()
	camera.local_player = prefab_player
	
	add_child(prefab_player)
	add_child(camera)

	print(children(get_children()))

func children(children):
	var children_names = []
	for i in children:
		children_names.append(i.name)
	return children_names

func _network_peer_disconnected(id):
	for i in get_children():
		if i.name == str(id):
			remove_child(i)

func _server_disconnected():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func _process(_delta):
	var key_esc = Input.is_action_just_pressed("esc")
	if key_esc:
		disconnect_from_server()
	if respawn:
		if spawn_time > 0:
			spawn_time -=1
		else:
			Respawn(respawn_id)
			spawn_time = spawn_cooldown
			respawn = false
	pass
func disconnect_from_server():
	var id = get_tree().get_network_unique_id()
	Network.host.disconnect_peer(id, true)
	get_tree().change_scene("res://Scenes/Menu.tscn")

func Respawn(id):
	var prefab_player = preload("res://Prefabs/prefab_Player.tscn").instance()	# load player
	prefab_player.name = str(id)
	prefab_player.transform.origin = Vector3(0,2,0)
	prefab_player.set_network_master(id)	
	
	var game = get_node("../Game")
	game.add_child(prefab_player)
	
	if prefab_player.is_network_master():
		var camera = get_node("/root/Game/prefab_camera")
		camera.local_player = prefab_player

