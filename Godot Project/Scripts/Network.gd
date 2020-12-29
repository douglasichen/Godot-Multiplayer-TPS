extends Node

const DEFAULT_IP = "127.0.0"		# local host
const DEFAULT_PORT = 40000			# place holder
const MAX_PLAYERS = 10			# place holder

var self_data = {id = 0, spawn_pos = Vector3(), pos = Vector3.ZERO}
var data = []
var loaded = false

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_network_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	# get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	pass

func _create_server():
	print("creating server...")
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	print("Create server successful")
	get_tree().set_network_peer(host)

	var host_id = get_tree().get_network_unique_id()
	var host_spawn_position = initialize_player_pos()
	self_data.id = host_id
	self_data.spawn_pos = host_spawn_position
	self_data.pos = host_spawn_position
	data.append(self_data)
	relay_data()
	load_game()	

func _connect_to_server(ip):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func _network_peer_connected(connected_id):
	if get_tree().is_network_server():
		# rpc_id(connected_id, "_send_new_player_info_to_client_from_server", connected_id, initialize_player_pos())
		pass
	elif connected_id == 1:									# if it is yourself
		var local_id = get_tree().get_network_unique_id()
		var spawn_pos = Vector3(0,1,0)					# initialize_player_pos()
		self_data.id = local_id
		self_data.spawn_pos = spawn_pos
		self_data.pos = spawn_pos
		rpc_id(1, "_send_self_data_to_server", self_data)
		print("Connected")

func _network_peer_disconnected(id):
	if get_tree().is_network_server():									# if is server
		var client_left_data = get_client_data_from_client_id(id)		# get the data of the client that left based off of their id
		data.erase(client_left_data)									# erase their data
		
		print("id: ", id, " has disconnected")							# debug disconnected
		relay_data()

func _server_disconnected():
	if !get_tree().is_network_server():
		print("Disconnected")
		print("The server you were connected to is shut down")	

# custom functions
# func send_server_data_to_clients():
# 	for i in data:
# 		if i.id != 1:
# 			rpc_id(i.id, "_r_send_server_data_to_clients", data)

func initialize_player_pos():
	var min_x = -9.5
	var max_x = 9.5
	var min_z = -9.5
	var max_z = 9.5
	var player_x = rand_range(min_x, max_x)									# random range x
	var player_y = 1														# locked y
	var player_z = rand_range(min_z, max_z)									# random range z
	var player_position = Vector3(player_x, player_y, player_z)
	return player_position

func get_client_data_from_client_id(client_id):
	for i in data:
		if i.id == client_id:
			return i
	return "Error, cannot find client data from client id."
	

func relay_data():
	print("Data: ", data)

func load_game():
	print("loaded scene")
	get_tree().change_scene("res://Scenes/Game.tscn")	# go to game scene
	for i in data:										# loop through all other clients and add this new player to the scene
		if i.id != self_data.id:
			rpc_id(i.id, "_add_player", self_data)
		
	loaded = true

func position_from_id(id):
	for i in data:
		if i.id == id:
			return i.pos

# remote functions
remote func _send_self_data_to_server(client_data):
	data.append(client_data)
	relay_data()
	for i in data:					# sending data to all the clients
		if i.id != 1:
			rpc_id(i.id, "_send_data_to_clients", data)

remote func _send_data_to_clients(server_data):
	print("sending data to clients")
	data = server_data
	if !loaded: load_game()

remote func _add_player(new_player_data):
	# print("new_player_data: ", new_player_data)
	var prefab_player = preload("res://Prefabs/prefab_Player.tscn").instance()
	prefab_player.name = str(new_player_data.id)
	prefab_player.transform.origin = new_player_data.spawn_pos
	prefab_player.set_network_master(new_player_data.id)
	var game = $"/root/Game"
	game.add_child(prefab_player)	
	pass

remote func _send_position_update_to_all_clients(id, position):
	if get_tree().current_scene.name != "Game":
		return
	var game = get_node("../Game")
	for i in game.get_children():
		if i.name == str(id):
			i.transform.origin = position
			break

remote func _send_gun_rot(id, gun_rot):
	if get_tree().current_scene.name != "Game":
		return
	var game = get_node("/root/Game")
	for i in game.get_children():
		if i.name == str(id):
			var gun = i.get_child(2)
			gun.rotation = gun_rot
remote func _send_bullet_position_and_rotation(pos, rot):
	var local_id = get_tree().get_network_unique_id()
	var bullet_cache = get_node("/root/Game/bullets")
	var bullet = preload("res://Prefabs/prefab_bullet.tscn").instance()
	bullet.transform.origin = pos
	bullet.rotation = rot
	bullet.set_network_master(local_id)
	bullet_cache.add_child(bullet)

remote func _send_kill_player(killed_player):
	var game = get_node("../Game")
	for child in game.get_children():
		if child.name == str(killed_player.id):
			
			game.remove_child(killed_player)



# remote functions
# remote func _send_self_data_to_server(client_data):
# 	data.append(client_data)
# 	relay_data()
# 	send_server_data_to_clients()
# 	pass

# remote func _send_new_player_info_to_client_from_server(client_id, new_player_pos):
# 	self_data.id = client_id
# 	self_data.spawn_pos = new_player_pos
# 	rpc_id(1, "_send_self_data_to_server", self_data)
# 	print("Received data from the server and sent it back.")
	
# 	pass

# remote func _r_send_server_data_to_clients(server_data):
# 	data = server_data
# 	if !loaded: load_game(self_data)


# remote func _send_position_update_to_all_clients(id, pos):
# 	var game = $"/root/Game/"
# 	for child in game.get_children():
# 		if child.name == str(id):
# 			child.transform.origin = pos
# 	pass
