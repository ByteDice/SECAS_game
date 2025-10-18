extends Node


enum CameraType {
	FIXED,
	FIXED_NO_PAN,
	FOLLOW,
	CUSTOM
}


class CharCamera:
	var camera_type: CameraType
	var custom_cam_type: Callable = Callable()
	
	var pos: Vector2 = Vector2.ZERO
	var offset: Vector2 = Vector2.ZERO
	
	var camera: Camera2D
	
	func _init(
		_camera: Camera2D,
		_camera_type: CameraType,
		_offset: Vector2 = Vector2.ZERO, 
		_pos: Vector2 = Vector2.ZERO
	):
		camera      = _camera
		camera_type = _camera_type
		offset      = _offset
		pos         = _pos
		if camera_type == CameraType.FIXED_NO_PAN:
			set_cam_smoothing(0.0)
	
	
	func process(_delta: float):
		pass
	
	func phys_process(_delta: float):
		if camera_type == CameraType.FIXED \
		   || camera_type == CameraType.FIXED_NO_PAN:
			camera.global_position = pos
		elif camera_type == CameraType.FOLLOW:
			camera.offset = offset
		else:
			camera.global_position = custom_cam_type.call()


	func set_cam_smoothing(a: float):
		camera.position_smoothing_speed = a

	
	func make_current(): camera.make_current()


	func teleport_camera(new_pos: Vector2):
		var first_state = camera.position_smoothing_enabled
		camera.position_smoothing_enabled = false
		camera.global_position = new_pos
		camera.position_smoothing_enabled = first_state
