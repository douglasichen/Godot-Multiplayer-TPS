extends RigidBody

export var speed = 25.0

onready var parent = get_parent()

var direction = Vector3.ZERO

var tag = "player"

func _physics_process(_delta):
	Input()
	Move()
	
	pass

func Input():
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")

	direction = Vector3.ZERO

	if right: direction.x = 1
	if left: direction.x = -1
	if down: direction.z = 1
	if up: direction.z = -1
	direction = direction.normalized()
	pass

func Move():
	if is_network_master():
		add_central_force(direction * speed)
		# update self data
		Network.self_data.pos = transform.origin
		var local_id = get_tree().get_network_unique_id()
		# update to all clients
		for i in Network.data:
			if i.id != local_id:
				Network.rpc_id(i.id, "_send_position_update_to_all_clients", local_id, Network.self_data.pos)
		
func _process(_delta):
	if (is_network_master()):
		gun_rot()
		gun_shoot()
	pass

func gun_rot():
	var cam = get_node("../prefab_camera/camera")	# camera child position
	if cam == null:
		return
	var gun = get_child(2)	# gun child position
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_length = 1000
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * ray_length

	var drop_plane = Plane(Vector3(0,1,0), transform.origin.y)	# use this plane for intersection
	var mouse_pos_3d = drop_plane.intersects_ray(from,to)
	
	if mouse_pos_3d == null:
		return

	gun.look_at(mouse_pos_3d, Vector3.UP)

	# send gun rot data
	var local_id = get_tree().get_network_unique_id()
	
	for i in Network.data:
		if i.id != local_id:
			Network.rpc_id(i.id, "_send_gun_rot", local_id, gun.rotation)
	pass

func gun_shoot():
	var shoot_button = Input.is_action_just_pressed("shoot")
	var local_id = get_tree().get_network_unique_id()
	var bullet_cache = get_node("../bullets")
	var gun = get_child(2)
	var gun_mesh = gun.get_child(0)
	var bullet = preload("res://Prefabs/prefab_bullet.tscn").instance()
	if (shoot_button):
		bullet.transform.origin = gun_mesh.global_transform.origin
		bullet.rotation = gun.rotation
		bullet.set_network_master(local_id)
		bullet_cache.add_child(bullet)

		# send to all clients
		for i in Network.data:
			if i.id != local_id:

				Network.rpc_id(i.id, "_send_bullet_position_and_rotation", bullet.transform.origin, bullet.rotation)
	pass
