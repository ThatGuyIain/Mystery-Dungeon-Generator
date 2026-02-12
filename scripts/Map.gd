extends Node2D

var root_node: Cell
var tile_size:int = 24
var paths: Array = []
var rooms: Array = []

var TILEMAP: TileMapLayer

@onready var max_rooms_text = $CanvasLayer/HBoxContainer2/VBoxContainer/Label
@onready var subdivision_depth_text = $CanvasLayer/HBoxContainer2/VBoxContainer/Label4
@onready var room_probabilty_text = $CanvasLayer/HBoxContainer2/VBoxContainer/Label5

@export var MAX_ROOMS: int = 10
@export var ROOM_SIZE: int = 5
@export var ROOM_PROBABILITY: int = 70
@export var SUBDIVISON_DEPTH: int = 4
@export var MAP_DIMENSIONS: Vector2i = Vector2i(100,60)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TILEMAP = get_node("TileMapLayer")
	generate_map()

func generate_map()-> void:
	TILEMAP.clear()
	paths.clear()
	rooms.clear()
	root_node = Cell.new(Vector2i(0,0),MAP_DIMENSIONS)
	root_node.split(SUBDIVISON_DEPTH, paths)
	make_room_array()
	queue_redraw()

func _draw():
	draw_tile_rect(MAP_DIMENSIONS,0,Vector2i(4,1))
	var rng = RandomNumberGenerator.new()
	var num_rooms = 0
	var gen_failed = 0
	
	var room_quantity = MAX_ROOMS 
	
	while num_rooms < room_quantity:
		
		var room_odds = rng.randf_range(0,100)
		
		# Padding factor
		var padding = Vector4i(
			rng.randi_range(2,3),
			rng.randi_range(2,3),
			rng.randi_range(2,3),
			rng.randi_range(2,3)
		)
		
		if room_odds > 100 - ROOM_PROBABILITY:
			
			var boxnum = rng.randi_range(0,rooms.size()-1)
			
			var leaf = rooms[boxnum]
			
			if leaf.suitable and not leaf.has_room:
			
				num_rooms += 1
				# Generate Rooms in each subdivided box 
				for x in range(leaf.size.x):
					for y in range(leaf.size.y):
						if not is_inside_padding(x,y,leaf,padding):
							leaf.has_room = true
							TILEMAP.set_cell(Vector2i(x + leaf.position.x,y + leaf.position.y),0,Vector2i(13,1))
			else:
				gen_failed += 1
				
				if gen_failed > 50:
					break
		
	draw_paths()
	
	draw_subdivisions()

# Create a random padding per subdivided box
func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			TILEMAP.set_cell(Vector2(x,y), source_id, atlas_coords)

func make_room_array():
	for leaf in root_node.get_leaves():
		if leaf.size.y < 6 and leaf.size.x < 6:
			leaf.suitable = false
			
		rooms.push_back(leaf)

func draw_subdivisions():
	for leaf in root_node.get_leaves():
	# Show area subdivisions
		draw_rect(
			Rect2(
				leaf.position.x * tile_size, # x
				leaf.position.y * tile_size, # y
				leaf.size.x * tile_size, # width
				leaf.size.y * tile_size # height
				), 
				Color.GREEN, # colour
				false
			)

func draw_paths():
	for path in paths:
		
		if path['left'].y == path['right'].y:
			# horizontal
			for i in range(path['right'].x - path['left'].x):
				TILEMAP.set_cell(Vector2i(path['left'].x+i,path['left'].y),0 ,Vector2i(13, 1))
				TILEMAP.set_cell(Vector2i(path['left'].x+i,path['left'].y-1),0 ,Vector2i(13, 1))
				TILEMAP.set_cell(Vector2i(path['left'].x+i,path['left'].y+1),0 ,Vector2i(13, 1))
		else:
			# vertical
			for i in range(path['right'].y - path['left'].y):
				TILEMAP.set_cell(Vector2i(path['left'].x,path['left'].y+i), 0, Vector2i(13, 1))
				TILEMAP.set_cell(Vector2i(path['left'].x-1,path['left'].y+i), 0, Vector2i(13, 1))
				TILEMAP.set_cell(Vector2i(path['left'].x+1,path['left'].y+i), 0, Vector2i(13, 1))


func _on_button_pressed() -> void:
	generate_map() # Replace with function body.

func _on_map_width_box_text_changed(new_text: String) -> void:
	if not int(new_text):
		pass
	else:
		MAP_DIMENSIONS.x = int(new_text)


func _on_map_length_box_text_changed(new_text: String) -> void:
	if not int(new_text):
		pass
	else:
		MAP_DIMENSIONS.y = int(new_text)


func _on_subdivison_slider_value_changed(value: float) -> void:
	SUBDIVISON_DEPTH = int(value)
	subdivision_depth_text.text = "Subdivision Depth: " + str(int(value))


func _on_room_probability_value_changed(value: float) -> void:
	ROOM_PROBABILITY = int(value)
	room_probabilty_text.text = "Room Probability: " + str(int(ROOM_PROBABILITY)) + "%"


func _on_room_quantity_text_changed(new_text: String) -> void:
	if not int(new_text):
		return
	
	if int(new_text) > 2500 or int(new_text) < 0:
		return
	
	MAX_ROOMS = int(new_text)
