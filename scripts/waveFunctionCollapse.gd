extends Node3D

const GRID_SIZE = Vector3(10, 3, 10)  # Adjust size as needed
const CELL_SIZE = 1.0

enum TileType {DIRT, FLOOR, WALL}

var grid = {}
var tiles = {
	TileType.DIRT: preload("res://scenes/models/dirt.tscn"),
	TileType.FLOOR: preload("res://scenes/models/floor.tscn"),
	TileType.WALL: preload("res://scenes/models/wall.tscn")
}

# Define rules for valid neighbors
var rules = {
	TileType.DIRT: {
		"top": [TileType.DIRT, TileType.FLOOR],
		"bottom": [TileType.DIRT],
		"sides": [TileType.DIRT, TileType.FLOOR]
	},
	TileType.FLOOR: {
		"top": [TileType.WALL],
		"bottom": [TileType.DIRT],
		"sides": [TileType.FLOOR, TileType.WALL]
	},
	TileType.WALL: {
		"top": [],
		"bottom": [TileType.FLOOR],
		"sides": [TileType.WALL]
	}
}

func _ready():
	generate_world()

func generate_world():
	# Initialize grid with all possibilities
	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			for z in range(GRID_SIZE.z):
				var pos = Vector3(x, y, z)
				grid[pos] = get_initial_possibilities(pos)
	
	# Start collapsing from bottom layer
	collapse_wave()

func get_initial_possibilities(pos: Vector3) -> Array:
	# Ground level can only be dirt
	if pos.y == 0:
		return [TileType.DIRT]
	return [TileType.DIRT, TileType.FLOOR, TileType.WALL]

func collapse_wave():
	while has_uncollapsed_cells():
		var pos = find_lowest_entropy_cell()
		if pos == null:
			break
		
		var possible_types = grid[pos]
		if possible_types.size() > 0:
			var selected_type = possible_types[randi() % possible_types.size()]
			place_tile(pos, selected_type)
			propagate_constraints(pos)

func has_uncollapsed_cells() -> bool:
	for cell in grid.values():
		if cell is Array and cell.size() > 1:
			return true
	return false

func find_lowest_entropy_cell() -> Vector3:
	var min_entropy = INF
	var min_pos = null
	
	for pos in grid:
		var cell = grid[pos]
		if cell is Array and cell.size() > 1 and cell.size() < min_entropy:
			min_entropy = cell.size()
			min_pos = pos
	
	return min_pos

func place_tile(pos: Vector3, type: int):
	grid[pos] = type
	var instance = tiles[type].instantiate()
	instance.position = pos * CELL_SIZE
	add_child(instance)

func propagate_constraints(pos: Vector3):
	var queue = [pos]
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_type = grid[current]
		
		# Check all neighbors
		for neighbor in get_neighbors(current):
			if not grid.has(neighbor):
				continue
			
			var neighbor_possibilities = grid[neighbor]
			if neighbor_possibilities is Array:
				var new_possibilities = get_valid_neighbors(current_type, current, neighbor)
				neighbor_possibilities = filter_possibilities(neighbor_possibilities, new_possibilities)
				
				if neighbor_possibilities.size() != grid[neighbor].size():
					grid[neighbor] = neighbor_possibilities
					queue.append(neighbor)

func get_neighbors(pos: Vector3) -> Array:
	var neighbors = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			for z in [-1, 0, 1]:
				var offset = Vector3(x, y, z)
				if offset != Vector3.ZERO:
					var neighbor = pos + offset
					if is_within_bounds(neighbor):
						neighbors.append(neighbor)
	return neighbors

func is_within_bounds(pos: Vector3) -> bool:
	return (pos.x >= 0 and pos.x < GRID_SIZE.x and
			pos.y >= 0 and pos.y < GRID_SIZE.y and
			pos.z >= 0 and pos.z < GRID_SIZE.z)

func get_valid_neighbors(type: int, from: Vector3, to: Vector3) -> Array:
	var direction = to - from
	if direction.y > 0:
		return rules[type]["top"]
	elif direction.y < 0:
		return rules[type]["bottom"]
	else:
		return rules[type]["sides"]

func filter_possibilities(current: Array, allowed: Array) -> Array:
	var result = []
	for type in current:
		if type in allowed:
			result.append(type)
	return result if result.size() > 0 else current
