extends Panel


enum Directions {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


var arrow = preload("res://assets/sprites/arrow.png")
var arrow_completed = preload("res://assets/sprites/arrow_green.png")
@onready var sequence: Array[Directions] = []
@onready var completed: Array[bool] = []

var arrow_el: TextureRect


func _ready():
	arrow_el = TextureRect.new()
	
	arrow_el.size = Vector2(40.0, 40.0)
	arrow_el.pivot_offset = arrow_el.size / 2
	arrow_el.texture = arrow
	arrow_el.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL


func set_sequence(new_sequence: Array[Directions]):
	sequence = new_sequence
	reset_completed()
	render_sequence()


func add_to_sequence(direction: Directions):
	sequence.append(direction)
	render_sequence()


func reset_sequence():
	sequence = []
	reset_sequence_render()


func reset_sequence_render():
	for el in self.get_children():
		self.remove_child(el)


func render_sequence():
	reset_sequence_render()
	
	for i in range(sequence.size()):
		var dir = sequence[i]
		var n_el = arrow_el.duplicate()
		n_el.position.x = (i - sequence.size() / 2.0)  * n_el.size.x
	
		var rot_deg = 0.0
	
		match dir:
			Directions.UP:    rot_deg = 0.0
			Directions.RIGHT: rot_deg = 90.0
			Directions.DOWN:  rot_deg = 180.0
			Directions.LEFT:  rot_deg = 270.0
		
		n_el.rotation = deg_to_rad(rot_deg)
		
		if completed[i]: n_el.texture = arrow_completed
	
		self.add_child(n_el)


func random_direction() -> Directions:
	var dir = randi_range(0, Directions.keys().size() - 1)
	
	return Directions.values()[dir]


func generate_sequence(length: int) -> Array[Directions]:
	var new_sequence: Array[Directions] = []
	
	for i in range(length):
		new_sequence.append(random_direction())
	
	return new_sequence


func try_complete_next(direction: Directions):
	if !self.visible: return
	
	var next = completed.find(false)
	
	if direction != sequence[next]: reset_completed()
	else: completed[next] = true
	render_sequence()


func is_fully_completed() -> bool:
	return false not in completed && !completed.is_empty()


func reset_completed():
	completed = []
	completed.resize(sequence.size())
	completed.fill(false)
