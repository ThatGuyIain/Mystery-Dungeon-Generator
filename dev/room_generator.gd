@tool
extends Node

class_name RoomGenerator

const TILE_DATA: Dictionary ={
	"floor":{
		"source_id": 0,
		"atlas_coords": Vector2(13,1)
	},	
	"wall":{
		"source_id": 0,
		"atlas_coords": Vector2(4,1)
	},
	"right_border":{
		"source_id": 0,
		"atlas_coords": Vector2(5,1)
	},
	"left_border":{
		"source_id": 0,
		"atlas_coords": Vector2(3,1)
	},
	"top_border":{
		"source_id": 0,
		"atlas_coords": Vector2(4,2)
	},
	"bottom_border":{
		"source_id": 0,
		"atlas_coords": Vector2(4,0)
	},
	"right_down":{
		"source_id": 0,
		"atlas_coords": Vector2(5,2)
	},
	"left_down":{
		"source_id": 0,
		"atlas_coords": Vector2(3,2)
	},
	"right_up":{
		"source_id": 0,
		"atlas_coords": Vector2(5,0)
	},
	"left_up":{
		"source_id": 0,
		"atlas_coords": Vector2(3,0)
	},
	"left_right":{
		"source_id": 0,
		"atlas_coords": Vector2(3,4)
	},
	"left_right_top":{
		"source_id": 0,
		"atlas_coords": Vector2(4,6)
	},
	"left_right_bottom":{
		"source_id": 0,
		"atlas_coords": Vector2(4,8)
	},
	"left_top_bottom":{
		"source_id": 0,
		"atlas_coords": Vector2(3,7)
	},
	"right_top_bottom":{
		"source_id": 0,
		"atlas_coords": Vector2(5,7)
	},
	"pillar":{
		"source_id": 0,
		"atlas_coords": Vector2(4,4)
	}
}

@export var num_rooms: int = 10
@export var gen_seed: int = 0
@export var randomize_seed: bool = true
@export var boundary_padding: int = 24
@export var map_dimensions: Vector2i = Vector2i(50,50)
@export var total_steps: int = 600
@export_tool_button("Generate Map") var map_gen_button = generate_map
@export var tilemap_layer: TileMapLayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	
func generate_map() -> void:
	
	if randomize_seed:
		gen_seed = randi()
	seed(gen_seed)
	
	tilemap_layer.clear()
	draw_tile_rect(map_dimensions,TILE_DATA.wall.source_id, TILE_DATA.wall.atlas_coords)
	draw_walker_generation(map_dimensions, boundary_padding, TILE_DATA.floor.source_id, TILE_DATA.floor.atlas_coords)
	draw_boarders(map_dimensions)
	



func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tilemap_layer.set_cell(Vector2(x,y), source_id, atlas_coords)
			
			
func draw_walker_generation(dimensions: Vector2i, padding: int, source_id: int, atlas_coords: Vector2i) -> void:
	var directions: Array = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var current_position: Vector2i = Vector2i(
		floor(dimensions.x/2.0),
		floor(dimensions.y/2.0))
	var bounds: Rect2i = Rect2i(0,0,dimensions.x,dimensions.y)
	
	for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]:
		bounds = bounds.grow_side(side,-padding)
		
	for i in range(total_steps):
		if bounds.has_point(current_position):
			tilemap_layer.set_cell(current_position,source_id,atlas_coords)
			
		var move_direction: Vector2i = directions.pick_random()
		var next_position: Vector2i = current_position + move_direction
		
		if bounds.has_point(next_position):
			current_position = next_position
		else:
			directions.shuffle()
			for d in directions:
				if bounds.has_point(current_position + d):
					current_position += d 
					break
			
func draw_boarders(dimensions: Vector2i) -> void: 
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			
			var cords: Vector2i = Vector2i(x,y)
			var current_tile: Vector2 = tilemap_layer.get_cell_atlas_coords(cords)
			
			if current_tile == TILE_DATA.wall.atlas_coords:
				check_empty_tile(cords,x,y)
				pass
				
func check_empty_tile(current_tile: Vector2i, x, y)-> void:
	
	var floor_tile = TILE_DATA.floor.atlas_coords
	floor_tile = Vector2i(floor_tile)
	
	var up = Vector2i(x,y+1)
	var down = Vector2i(x,y-1)
	var left = Vector2i(x-1,y)
	var right = Vector2i(x+1,y)
	
	#wall position relative to floor tiles
	#left,right,up,down
	var relative_position = [false,false,false,false] 
	
	if tilemap_layer.get_cell_atlas_coords(left) == floor_tile:
		relative_position[0] = true
	if tilemap_layer.get_cell_atlas_coords(right) == floor_tile:
		relative_position[1] = true
	if tilemap_layer.get_cell_atlas_coords(up) == floor_tile:
		relative_position[2] = true
	if tilemap_layer.get_cell_atlas_coords(down) == floor_tile:
		relative_position[3] = true
		
	

	if relative_position[0] && relative_position[1] && relative_position[2]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_right_top.source_id,TILE_DATA.left_right_top.atlas_coords)
	elif relative_position[1] && relative_position[2] && relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.right_top_bottom.source_id,TILE_DATA.right_top_bottom.atlas_coords)
	elif relative_position[0] && relative_position[1] && relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_right_bottom.source_id,TILE_DATA.left_right_bottom.atlas_coords)
	elif relative_position[0] && relative_position[2] && relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_top_bottom.source_id,TILE_DATA.left_top_bottom.atlas_coords)
	elif relative_position[0] && relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_up.source_id,TILE_DATA.left_up.atlas_coords)
	elif relative_position[0] && relative_position[2]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_down.source_id,TILE_DATA.left_down.atlas_coords)
	elif relative_position[1] && relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.right_up.source_id,TILE_DATA.right_up.atlas_coords)
	elif relative_position[1] && relative_position[2]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.right_down.source_id,TILE_DATA.right_down.atlas_coords)
	elif relative_position[1] && relative_position[0]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_right.source_id,TILE_DATA.left_right.atlas_coords)
	elif relative_position[0]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.left_border.source_id,TILE_DATA.left_border.atlas_coords)
	elif relative_position[1]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.right_border.source_id,TILE_DATA.right_border.atlas_coords)
	elif relative_position[2]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.top_border.source_id,TILE_DATA.top_border.atlas_coords)
	elif relative_position[3]:
		tilemap_layer.set_cell(current_tile,TILE_DATA.bottom_border.source_id,TILE_DATA.bottom_border.atlas_coords)
	
