extends StaticBody2D


@export var biscuit_increment: float


@onready var sequence: Array[int] = []
@onready var is_active: bool = false
@onready var biscuit_fraction: float = 0.0
var hud: Panel
var player: CharacterBody2D


func _process(delta: float):
	$ProgressBar.value = biscuit_fraction * 100
	if biscuit_fraction < 1.0:
		biscuit_fraction += biscuit_increment * delta
		biscuit_fraction = min(biscuit_fraction, 1.0)
	
	if not hud: return
	
	if hud.is_fully_completed() && is_active:
		sequence = hud.generate_sequence(5)
		hud.set_sequence(sequence)
		biscuit_fraction = 0.0
		hud.hide()
		player.try_add_biscuit()
	
	if is_active && biscuit_fraction >= 1.0: hud.show()
	
	if sequence.is_empty():
		sequence = hud.generate_sequence(5)
		hud.set_sequence(sequence)


func _on_trigger_body_entered(body: Node2D):
	if body is not CharacterBody2D: return
	is_active = true
	
	if not hud: hud = body.get_node("KeySequence")
	if not player: player = body


func _on_trigger_body_exited(body: Node2D):
	if body is not CharacterBody2D: return
	is_active = false
	hud.hide()
