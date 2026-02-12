@tool
extends Node

class_name DungeonGenerator

@export var num_rooms: int = 10
@export var min_room_size: int = 2
@export var gen_seed: int = 0
@export var randomize_seed: bool = true
@export var boundary_padding: int = 24
@export var map_dimensions: Vector2i = Vector2i(120,70)
@export_tool_button("Generate Map") var map_gen_button = generate_map
@export var tilemap_layer: TileMapLayer

var root_node: Cell


const TILE_DATA: Dictionary ={
	"floor":{
		"source_id": 0,
		"atlas_coords": Vector2(13,1)
	},	
	"wall":{
		"source_id": 0,
		"atlas_coords": Vector2(4,1)
	},
	}
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map()
	pass # Replace with function body.

func generate_map() -> void:
	
	if randomize_seed:
		gen_seed = randi()
	seed(gen_seed)
	
	tilemap_layer.clear()
	draw_tile_rect(map_dimensions,TILE_DATA.wall.source_id, TILE_DATA.wall.atlas_coords)
	

func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tilemap_layer.set_cell(Vector2(x,y), source_id, atlas_coords)
