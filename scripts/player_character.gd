extends CharacterBody2D


var biscuit = preload("res://assets/sprites/biscuit.png")


@export_group("Movement")
@export var movement_type: LibCharMove.MovementType
@export_subgroup("Moving")
@export var speed: float
@export var sprint_speed: float
@export_subgroup("Jumping")
@export var jump_power: float
@export var extra_jumps: int
@export var coyote_time: float
@export var jump_buffer_timer: float
@export_subgroup("Dashing")
@export var dash_type: LibCharMove.DashType
@export var aerial_dash_count: int
@export var vel_multiplier_after_dash: float
@export var dash_speed: float
@export var dash_dur: float
@export var dash_cd: float
@export_subgroup("Physics")
@export var gravity: float
@export var terminal_vel: float

@export_group("Generic")
@export_subgroup("Health")
@export var max_health: float
@export var starting_health: float
@export var iframe_dur: float
@export_subgroup("Camera")
@export var camera_type: LibCharCam.CameraType
@export var camera_offset: Vector2

@export_group("Biscuit")
@export var max_biscuits: int


var character: LibChar.Char
var hud: Control
@onready var is_flipped: bool = false
@onready var biscuit_count: int = 0

func _ready():
	floor_max_angle = deg_to_rad(40.0)
	match movement_type:
		LibCharMove.MovementType.PLATFORMER:
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		LibCharMove.MovementType.TOP_DOWN:
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	# custom movement so we do this
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	
	var char_movement = LibCharMove.CharMovement.new(
		movement_type,
		speed, sprint_speed,
		jump_power, extra_jumps, coyote_time, jump_buffer_timer,
		dash_type, aerial_dash_count, vel_multiplier_after_dash,
		dash_speed, dash_dur, dash_cd,
		gravity, terminal_vel
	)
	
	var char_camera = LibCharCam.CharCamera.new(
		$Camera,
		camera_type,
		camera_offset,
		Vector2.ZERO
	)
	
	character = LibChar.Char.new(
		char_movement, char_camera,
		max_health, starting_health, iframe_dur
	)
	
	character.movement.custom_movement_func = move_logic
	
	character.camera.make_current()
	character.camera.pos = $Camera.global_position


var mouse_pos: Vector2 = Vector2.ZERO
var look_dir: Vector2 = Vector2.ZERO


func _process(delta: float):
	mouse_pos = get_viewport().get_mouse_position()
	look_dir = (mouse_pos - self.global_position).normalized()
	character.process(look_dir, mouse_pos, delta)
	sequence_logic()


func _physics_process(delta: float):
	character.phys_process(delta)
	# move_and_slide() automatically computes delta :(
	velocity = character.movement.velocity / delta
	move_and_slide()
	character.movement.is_grounded = is_on_floor()


func move_logic(delta: float):
	var dir_vector = (mouse_pos - (get_viewport_rect().size / 2)) - self.global_position
	character.movement.velocity = dir_vector * character.movement.speed * delta
	
	if dir_vector.x < 0 && !is_flipped:
		$AnimationPlayer.play("flip")
		is_flipped = true
	if dir_vector.x > 0 && is_flipped:
		$AnimationPlayer.play_backwards("flip")
		is_flipped = false


func sequence_logic():
	var dir: int = -1
	
	if Input.is_action_just_pressed("up"):
		dir = $KeySequence.Directions.UP
	elif Input.is_action_just_pressed("down"):
		dir = $KeySequence.Directions.DOWN
	elif Input.is_action_just_pressed("left"):
		dir = $KeySequence.Directions.LEFT
	elif Input.is_action_just_pressed("right"):
		dir = $KeySequence.Directions.RIGHT
	
	if dir != -1: $KeySequence.try_complete_next(dir)


func reset_biscuits():
	for el in $Sprite/BiscuitPos.get_children():
		$Sprite/BiscuitPos.remove_child(el)


func render_biscuits():
	const BISCUIT_OFFSET = 5.0
	
	reset_biscuits()
	
	for i in range(biscuit_count):
		var offset = BISCUIT_OFFSET
		if i == 0: offset = 0
		var b = Sprite2D.new()
		b.texture = biscuit
		b.position.y = -i * (biscuit.get_height() - offset)
		
		$Sprite/BiscuitPos.add_child(b)


func try_add_biscuit() -> bool:
	if biscuit_count >= max_biscuits: return false
	biscuit_count += 1
	render_biscuits()
	return true


func remove_biscuit():
	if biscuit_count <= 0: return
	biscuit_count -= 1
	render_biscuits()
