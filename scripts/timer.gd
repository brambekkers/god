extends Label

var elapsed_time: float = 0.0

func _ready() -> void:
	elapsed_time = 0.0
	update_display()

func _process(delta: float) -> void:
	elapsed_time += delta
	update_display()

func update_display() -> void:
	var minutes: int = int(elapsed_time / 60)
	var seconds: int = int(elapsed_time) % 60
	var milliseconds: int = int((elapsed_time - int(elapsed_time)) * 100)
	text = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

func reset_timer() -> void:
	elapsed_time = 0.0
	update_display()
