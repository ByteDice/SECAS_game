extends Node


class Char:
	# Children
	var movement: LibCharMove.CharMovement
	var camera: LibCharCam.CharCamera
	
	# Health
	var max_health: float
	var iframe_dur: float
	# Updating
	var health: float = 1.0
	var is_dead: bool = false
	var iframe_timer: float = 0.0
	var mouse_pos: Vector2 = Vector2.ZERO
	var look_dir: Vector2 = Vector2.ZERO
	var sprite_rotation: float = 0.0
	
	func _init(
		_movement: LibCharMove.CharMovement,
		_camera: LibCharCam.CharCamera,
		_max_health: float,
		_starting_health: float,
		_iframe_dur: float
	):
		movement           = _movement
		camera             = _camera
		max_health         = _max_health
		health             = _starting_health
		iframe_dur         = _iframe_dur

	func process(_look_dir: Vector2, _mouse_pos: Vector2, delta: float):
		look_dir = _look_dir
		mouse_pos = _mouse_pos
		movement.process(look_dir, delta)
		camera  .process(delta)
		if Input.is_key_pressed(KEY_H): heal(25); print(health)
		if Input.is_key_pressed(KEY_K): damage(25); print(health)
		
	func phys_process(delta: float):
		movement.phys_process(delta)
		camera  .phys_process(delta)
		if iframe_timer > 0.0: iframe_timer -= delta
		
	func heal(a: float):
		health += abs(a)
		health = min(health, max_health)
		is_dead = a > 0
	func damage(a: float, ignore_iframes: bool = false, custom_iframes: float = -1):
		if (iframe_timer <= 0 || ignore_iframes):
			health -= abs(a)
		
			if (custom_iframes > 0): iframe_timer = custom_iframes
			else:                    iframe_timer = iframe_dur
		
			health = max(0, health)
			is_dead = a > 0
