@tool
class_name Cell extends Node

var left_child: Cell
var right_child: Cell
var position: Vector2i
var size: Vector2i
var has_room: bool
var suitable: bool

func _init(position,size) -> void:
	self.position = position
	self.size = size
	self.has_room = false
	self.suitable = true

func get_leaves():
	if not (left_child && right_child):
		return [self]
	else:
		return left_child.get_leaves() + right_child.get_leaves()
		
func split(remaining,paths):
	var rng = RandomNumberGenerator.new()
	var split_percent = rng.randf_range(0.3,0.7) # splits will be between 30% and 70%
	var split_horizontal = size.y >= size.x # if it is taller than it is wide
	
	
	if(split_horizontal):
		# horizontal
		var left_height = int(size.y * split_percent)
		left_child = Cell.new(position, Vector2i(size.x, left_height))
		right_child = Cell.new(
			Vector2i(position.x, position.y + left_height), 
			Vector2i(size.x, size.y - left_height)
		)
	else:
		# vertical
		var left_width = int(size.x * split_percent)
		left_child = Cell.new(position, Vector2i(left_width, size.y))
		right_child = Cell.new(
			Vector2i(position.x + left_width, position.y), 
			Vector2i(size.x - left_width, size.y)
		)

	if(remaining > 0):
		left_child.split(remaining - 1, paths)
		right_child.split(remaining - 1, paths)
		
	paths.push_back({'left': left_child.get_center(), 'right': right_child.get_center()})

func get_center():
	return Vector2i(position.x + size.x / 2, position.y + size.y / 2)
