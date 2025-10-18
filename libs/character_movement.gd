extends Node


enum MovementType {
	PLATFORMER,
	TOP_DOWN,
	CUSTOM,
	NONE
}
enum DashType {
	KEYS,
	HORIZONTAL_KEYS,
	MOUSE,
	CONTINOUS_MOUSE,
	SPRINT,
	NONE
}


class CharMovement:
	var movement_type: MovementType
	var custom_movement_func: Callable = Callable()
	
	# EXTRA (that may or may not be added)
	# Coyote time
	# Input buffer
	
	# Params
	var speed: float
	var sprint_speed: float
	var jump_power: float
	var extra_jumps: int
	var coyote_time: float
	var jump_buffer_time: float
	var dash_type: DashType
	var aerial_dash_count: int
	var vel_multiplier_after_dash: float
	var dash_speed: float
	var dash_dur: float
	var dash_cd: float
	# Physics Params
	var gravity: float
	var terminal_vel: float
	
	# Updating
	var velocity: Vector2 = Vector2.ZERO
	
	var is_grounded: bool = false
	
	var can_jump: bool = true
	var can_move: bool = true
	
	var jumps: int = 0
	var coyote_timer: float = 0.0
	var jump_buffer_timer: float = 0.0
	
	var is_dashing: bool = false
	var is_dash_cd: bool = false
	var dash_timer: float = 0.0
	var dash_cd_timer: float = 0.0
	var aerial_dashes: int = 0
	
	var look_dir: Vector2 = Vector2.ZERO
	var last_look_dir: Vector2 = Vector2.ZERO
	var move_dir: Vector2 = Vector2.ZERO
	var move_dir_x: float = 0.0
	var last_move_dir: Vector2 = Vector2.ZERO
	var last_move_dir_x: float = 0.0
	var was_dash_pressed: bool = false
	var was_jump_pressed: bool = false
	var is_jump_held: bool = false

	func _init(
		_movement_type: MovementType,
		_speed: float,
		_sprint_speed: float,
		_jump_power: float,
		_extra_jumps: int,
		_coyote_time: float,
		_jump_buffer_time: float,
		_dash_type: DashType,
		_aerial_dash_count: int,
		_vel_multiplier_after_dash: float,
		_dash_speed: float,
		_dash_dur: float,
		_dash_cd: float,
		_gravity: float,
		_terminal_vel: float
	):
		movement_type = _movement_type
		speed         = _speed
		sprint_speed  = _sprint_speed
		jump_power    = _jump_power
		extra_jumps   = _extra_jumps
		coyote_time   = _coyote_time
		dash_type     = _dash_type
		dash_speed    = _dash_speed
		dash_dur      = _dash_dur
		dash_cd       = _dash_cd
		gravity       = _gravity
		terminal_vel  = _terminal_vel
		
		# Long names
		jump_buffer_time = _jump_buffer_time
		aerial_dash_count = _aerial_dash_count
		vel_multiplier_after_dash = _vel_multiplier_after_dash

	func set_custom_movement_func(function: Callable):
		custom_movement_func = function


	func process(_look_dir: Vector2, _delta: float):
		look_dir = _look_dir
		
		move_dir = Input.get_vector("left", "right", "up", "down")
		move_dir_x = Input.get_axis("left", "right")
		was_dash_pressed = Input.is_action_just_pressed("dash")
		was_jump_pressed = Input.is_action_just_pressed("jump")
		is_jump_held = Input.is_action_pressed("jump")
		
		if movement_type == MovementType.PLATFORMER:
			was_jump_pressed = was_jump_pressed || Input.is_action_just_pressed("jump_alt")
			is_jump_held = is_jump_held || Input.is_action_pressed("jump_alt")
	
	func phys_process(delta: float):
		move_logic(delta)
		jump_logic(delta)
		# dash overrides other movement
		dash_logic(delta)
		
		physics(delta)


	func dash_logic(delta: float):
		if is_grounded: aerial_dashes = 0
		
		if  was_dash_pressed && !is_dashing && !is_dash_cd:
			if movement_type == MovementType.TOP_DOWN \
			   || aerial_dashes < aerial_dash_count \
			   || is_grounded:
				is_dashing = true
				last_look_dir = look_dir
				last_move_dir = move_dir
				last_move_dir_x = move_dir_x
				aerial_dashes += 1
		
		if is_dashing:
			dash_timer += delta
			dash_velocity(delta)
			
		if dash_timer >= dash_dur:
			is_dashing = false
			is_dash_cd = true
			dash_timer = 0.0
			velocity *= vel_multiplier_after_dash
		
		if is_dash_cd:
			dash_cd_timer += delta
		
		if dash_cd_timer >= dash_cd:
			is_dash_cd = false
			dash_cd_timer = 0.0

	func dash_velocity(delta: float):
		match dash_type:
			DashType.KEYS:            velocity   = last_move_dir   * dash_speed * delta
			DashType.HORIZONTAL_KEYS: velocity.x = last_move_dir_x * dash_speed * delta
			DashType.MOUSE:           velocity   = last_look_dir   * dash_speed * delta
			DashType.CONTINOUS_MOUSE: velocity   = look_dir        * dash_speed * delta
			DashType.SPRINT: pass
			DashType.NONE: pass


	func move_logic(delta: float):
		if can_move: movement_velocity(delta)

	func movement_velocity(delta: float):
		var final_speed = speed
		if dash_type == DashType.SPRINT && Input.is_action_pressed("dash"):
			final_speed = sprint_speed
		
		match movement_type:
			MovementType.TOP_DOWN:   velocity   = move_dir   * final_speed * delta
			MovementType.PLATFORMER: velocity.x = move_dir_x * final_speed * delta
			MovementType.CUSTOM: custom_movement_func.call(delta)
			MovementType.NONE: pass


	func jump_logic(delta: float):
		if is_grounded: jumps = 0
		
		if !can_jump || movement_type != MovementType.PLATFORMER: return
		
		# Spaghetti restaurant: $0.0 for 1 spaghett
		if is_grounded && was_jump_pressed:	jump()
		elif coyote_timer < coyote_time \
			 && was_jump_pressed && jumps == 0: jump()
		elif jumps <= extra_jumps \
			 && !is_grounded && was_jump_pressed: jump()
		elif is_jump_held && is_grounded \
			 && jump_buffer_timer < jump_buffer_time:
				jumps = 0; jump()
	
		if !is_grounded \
		   && coyote_timer < coyote_time:
			coyote_timer += delta
		
		if is_jump_held && !is_grounded \
		   && jump_buffer_timer < jump_buffer_time:
			jump_buffer_timer += delta
			
		if is_grounded:
			coyote_timer = 0.0
		if !is_jump_held: jump_buffer_timer = 0.0
	
	func jump():
		velocity.y = jump_power * -1.0
		jumps += 1


	func physics(delta: float):
		if movement_type != MovementType.PLATFORMER: return
		
		if !is_grounded:
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, terminal_vel * delta)
		else:
			velocity.y = min(0, velocity.y)
