### ----------------------------------------------------
### Handles movement of the camera
### ----------------------------------------------------
extends Camera2D


func update_camera_pos(CameraFocusObject:Node2D):
	var objPos = CameraFocusObject.global_position
	set_global_position(objPos)
	current = true
