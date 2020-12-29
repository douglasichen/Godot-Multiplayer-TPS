extends AudioStreamPlayer3D

export var random_pitch_variant = 0.1

var destroy_time = 100
onready var parent = get_node("/root/Game/sound_clutter")

func _ready():
	pitch_scale = rand_range(1-random_pitch_variant, 1+random_pitch_variant)
	
	play(0)

func _process(_delta):
	if destroy_time > 0: destroy_time -= 1
	else:
		parent.remove_child(get_parent())
	pass
