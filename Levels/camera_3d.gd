extends Node3D

@export var head_bone_name: String =  "mixamorig_HeadTop_End"
@export var skeleton: Skeleton3D 
@export var camera: Camera3D 

func _ready():
	# Ensure the camera starts at the correct position
	update_camera_position()

func _process(delta):
	# Continuously update the camera position to follow the head bone
	update_camera_position()

func update_camera_position():
	var head_bone_index = skeleton.find_bone(head_bone_name)
	if head_bone_index != -1:
		var bone_transform = skeleton.get_bone_global_pose(head_bone_index)
		camera.global_transform = bone_transform
