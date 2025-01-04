extends StaticBody3D  # or Area3D if you used that instead

func _ready():
	pass

# If using StaticBody3D
func _on_player_collision(_collision: KinematicCollision3D) -> String:
	print("Player touched the chest!")
	return 'chest'
	# Add your chest opening logic here
