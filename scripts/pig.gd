extends CharacterBody2D


enum States {
	WALKING,
	PANIC,
	WAITING
}

@export var min_state_dur: float
@export var max_state_dur: float
@export var min_time_till_attack: float
@export var max_time_till_attack: float
@export var min_attack_duration: float
@export var max_attack_duration: float
@export var walk_speed: float
@export var panic_speed: float
@export var seagull_speed: float

@onready var is_attacked: bool = false # I shouldve made these an enum tbh
@onready var attack_approaching: bool = false
@onready var is_retreating: bool = false
@onready var walk_dir = Vector2.ZERO
@onready var is_flipped: bool = false
@onready var seagull_is_flipped: bool = false
@onready var seagull_dir = Vector2.ZERO
@onready var seagull_home_pos = Vector2.ZERO
@onready var received_biscuit: bool = false

var time_till_attacked: float
var time_till_abducted: float
var current_state: States
var state_duration: float


func _ready():
	time_till_attacked = randf_range(min_time_till_attack, max_time_till_attack)
	change_walk_dir()
	new_state()


func _physics_process(delta: float):
	if !is_attacked:
		match current_state:
			States.WALKING: act_walking(delta)
			States.PANIC: act_walking(delta, true)
			States.WAITING: 
				if !$PigAnimations.current_animation == "flip":
					$PigAnimations.stop()
	else:
		if time_till_abducted > 0: act_walking(delta, true)
		else: pass
		
	attack_logic(delta)
	
	if walk_dir.x < 0 && !is_flipped:
		$PigAnimations.play("flip")
		is_flipped = true
	elif walk_dir.x > 0 && is_flipped:
		$PigAnimations.play_backwards("flip")
		is_flipped = false
	
	state_duration -= delta
	if time_till_attacked > 0: time_till_attacked -= delta
	if state_duration <= 0.0: new_state()


func new_state():
	state_duration = randf_range(min_state_dur, max_state_dur)
	var next_state = randi_range(0, States.size() - 1)
	
	if next_state == States.PANIC && randf() < 0.95:
		next_state = States.WALKING if randi_range(0, 1) == 0 else States.WAITING
	
	current_state = States.values()[next_state]


func act_walking(delta: float, panicked: bool = false):
	var average_time_to_switch_dir: float = 2.0 if !panicked else 0.2
	var should_switch_dir = randf() < delta / average_time_to_switch_dir
	if should_switch_dir: change_walk_dir()
	self.velocity = walk_dir * (walk_speed if !panicked else panic_speed)
	self.move_and_slide()
	if !$PigAnimations.current_animation == "flip":
		$PigAnimations.play("walk")


func change_walk_dir():
	walk_dir = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()


func attack_logic(delta: float):
	if time_till_attacked <= 0.0 && !(is_attacked || attack_approaching || is_retreating):
		attack_approaching = true
		seagull_home_pos = Vector2(
			randf_range(-3000.0, 3000.0),
			randf_range(-1920.0, -2500.0)
		)
		$Seagull.global_position = seagull_home_pos
		$Seagull.visible = true
		$Seagull.play("fly")

	attack_approaching_logic(delta)
	is_attacked_logic(delta)
	retreating_logic(delta)
	
	if seagull_dir.x < 0 && !seagull_is_flipped:
		$SeagullAnimations.play("flip")
		seagull_is_flipped = true
	elif seagull_dir.x > 0 && seagull_is_flipped:
		$SeagullAnimations.play_backwards("flip")
		seagull_is_flipped = false


func attack_approaching_logic(delta: float):
	if !attack_approaching: return
	
	seagull_dir = ($PigSprite/SeagullAttackPos.global_position - $Seagull.global_position).normalized()
	
	$Seagull.global_position += seagull_dir * seagull_speed * delta
	
	var dist = $Seagull.global_position.distance_to($PigSprite/SeagullAttackPos.global_position)
	if dist < 15.0:
		$Seagull.global_position = $PigSprite/SeagullAttackPos.global_position
		attack_approaching = false
		is_attacked = true
		$Seagull.play("attack")
		if !$PigAnimations.current_animation == "flip": $PigAnimations.stop()
		time_till_abducted = randf_range(min_attack_duration, max_attack_duration)


func is_attacked_logic(delta: float):
	if !is_attacked: return
	
	if time_till_abducted <= 0.0:
		seagull_dir = (seagull_home_pos - $Seagull.global_position).normalized()
		self.global_position += seagull_dir * seagull_speed * delta
		$PigSprite.self_modulate.a = 0.5
		$Collision.disabled = true
	
	if self.global_position.y < -get_viewport_rect().size.y - 300.0: 
		get_tree().current_scene.pigs_abducted += 1
		get_parent().remove_child(self)
	
	if received_biscuit:
		is_attacked = false
		received_biscuit = false	
		is_retreating = true
		get_tree().current_scene.pigs_saved += 1
	
	time_till_abducted -= delta


func retreating_logic(delta: float):
	if !is_retreating: return
	
	seagull_dir = (seagull_home_pos - $Seagull.global_position).normalized()
	$Seagull.global_position += seagull_dir * seagull_speed * delta

	if $Seagull.global_position.y < -get_viewport_rect().size.y - 300.0:
		is_retreating = false
		$Seagull.global_position = seagull_home_pos


func _on_feed_zone_body_entered(body: Node2D):
	if body is not CharacterBody2D: return
	if body.name != "PlayerCharacter": return
	
	if is_attacked && body.biscuit_count > 0 && time_till_abducted > 0.0:
		received_biscuit = true
		body.remove_biscuit()
