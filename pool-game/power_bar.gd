extends Node2D

var charging: bool = false
var charge_time: float = 0.0
var max_charge_time: float = 2.0

func start_charge():
	charging = true
	charge_time = 0.0

func stop_charge():
	charging = false
	charge_time = 0.0
	queue_redraw()

func _process(delta):
	if charging:
		charge_time = min(charge_time + delta, max_charge_time)
	queue_redraw()  # redraw every frame

func get_power_ratio() -> float:
	return clamp(charge_time / max_charge_time, 0.0, 1.0)

func _draw():
	var bar_width = 20
	var bar_height = 150
	var bar_pos = Vector2(20, 20)  # top-left screen

	# Draw background
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.2, 0.2, 0.2))

	if charging:
		var t = get_power_ratio()
		var fill_height = bar_height * t
		var fill_color = Color(1.0, 1.0 - t, 0.0)  # yellow → red
		draw_rect(Rect2(bar_pos.x, bar_pos.y + bar_height - fill_height, bar_width, fill_height), fill_color)
