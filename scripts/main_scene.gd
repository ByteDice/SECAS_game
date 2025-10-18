extends Node2D


var pig = preload("res://actors/pig.tscn")
var game_over = preload("res://ui/game_over.tscn")


@export var pig_amount: int

@onready var pigs_abducted: int = 0
@onready var pigs_saved: int = 0


func _ready():
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	
	for _i in range(pig_amount):
		var p = pig.instantiate()
		
		p.global_position = Vector2(
			randf_range($FarmTopLeft.global_position.x, $FarmBottomRight.global_position.x),
			randf_range($FarmTopLeft.global_position.y, $FarmBottomRight.global_position.y)
		)
		self.add_child(p)


func _process(_delta: float):
	if pigs_abducted > 0:
		var g = game_over.instantiate()
		g.saved_pigs = pigs_saved
		var tree = get_tree()
		tree.root.add_child(g)
		var old_scene = tree.current_scene
		tree.current_scene = g
		old_scene.free()
