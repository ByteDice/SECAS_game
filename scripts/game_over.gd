extends Control


var saved_pigs: int
@onready var has_reddend = false


func _ready():
	if not saved_pigs: saved_pigs = 0
	$Saved.text = "At least you saved them %s times" % saved_pigs
	if saved_pigs == 0: $Saved.text = "You couldn't even save one abduction?"
	$AnimationPlayer.play("fade_in")
	

func _process(_delta: float):
	if !$AnimationPlayer.current_animation == "fade_in" \
	   && saved_pigs == 0 && !has_reddend:
		$AnimationPlayer.play("redden")
		has_reddend = true


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
