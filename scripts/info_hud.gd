extends Control

@export var hp_animation_dur: float

var healthbar_full_size: Vector2
var hp_value: Panel

var hp_tween: Tween

func _ready():
	healthbar_full_size = $HealthbarBase/HealthbarValue.size
	hp_value = $HealthbarBase/HealthbarValue


## The amount is a value between 0..1
func set_health(a: float):
	var f_pos: float = healthbar_full_size.y - (a * hp_value.size.y)
	var user_favor: float = sin(a * PI) * 10
	f_pos -= user_favor
	f_pos = clamp(f_pos, 0, healthbar_full_size.y)
	if hp_value.position.y == f_pos: return;
	
	if hp_tween && hp_tween.is_running(): hp_tween.kill()
	hp_tween = create_tween()
	hp_tween.set_trans(Tween.TRANS_LINEAR)
	
	hp_tween.tween_property(
		hp_value,
		"position:y",
		f_pos,
		hp_animation_dur
	)
