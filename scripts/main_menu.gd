extends Control

var seagull = preload("res://actors/seagull_particle.tscn")

@export var square_rot: float

var play_button: Button
var quit_button: Button
var credit_button: Button

@onready var times_quit: int = 0
@onready var times_credited: int = 0

func _ready():
	play_button = $InteractiblesContainer/ButtonsContainer/PlayButton
	quit_button = $InteractiblesContainer/ButtonsContainer/QuitButton
	credit_button = $InteractiblesContainer/ButtonsContainer/CreditsButton


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	quit_button.text = "No."
	times_quit += 1
	if times_quit == 10:
		quit_button.disabled = true
		quit_button.text = "This game is too\nSuper Epic Cool Awesome Stuff\nfor you to leave."


func _process(delta: float):
	$BgSquare.rotation += square_rot * delta
	var AVG_TIME_FOR_SEAGULL: float = 0.5
	var should_seagull: bool = randf() < delta / AVG_TIME_FOR_SEAGULL
	
	if should_seagull:
		var s = seagull.instantiate()
		$Seagulls.add_child(s)


func _on_credits_button_pressed() -> void:
	credit_button.text = "Are you stupid?"
	times_quit += 1
	if times_quit == 3:
		credit_button.disabled = true
		credit_button.text = "Byte Dice"
