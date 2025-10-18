extends AnimatedSprite2D


@export var speed: float

var dir: Vector2

@onready var pos = Vector2(
	-100.0 if randi_range(0, 1) else get_viewport_rect().size.x,
	randf_range(0, 1)
)


func _ready():
	dir = Vector2(
		randf_range(0, 1) * (-1 if pos.x > 0 else 1),
		randf_range(-0.2, 0.2)
	).normalized()
	
	pos.y *= get_viewport_rect().size.y
	self.global_position = pos
	if dir.x < 0: self.flip_h = true


func _process(delta: float):
	self.global_position += dir * speed * delta
	self.play("default")
