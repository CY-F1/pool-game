extends Node2D

@export var ball_scene: PackedScene
@export var min_power: float = 200
@export var max_power: float = 1000
@export var max_charge_time: float = 2.0	# seconds to reach full power

@onready var power_bar = get_node("../CanvasLayer/Power Bar")  # adjust path


var charging: bool = false
var charge_time: float = 0.0
var aim_direction: Vector2 = Vector2.ZERO
var mouse_position: Vector2 = Vector2.ZERO

func _process(delta):
	if charging:
		# Increase charge over time (cap at max)
		charge_time = min(charge_time + delta, max_charge_time)
	queue_redraw()	# redraw the aiming line every frame

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		aim_direction = (mouse_position - global_position).normalized()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start charging
				charging = true
				charge_time = 0.0
				power_bar.start_charge()
			else:
				# Release shot
				if charging:
					shoot_ball(mouse_position)
					charging = false
					charge_time = 0.0
					power_bar.stop_charge()

func shoot_ball(target_position: Vector2):
	var ball = ball_scene.instantiate()
	ball.global_position = global_position
	get_parent().add_child(ball)

	# Calculate power based on charge time
	var t = charge_time / max_charge_time
	var power = lerp(min_power, max_power, t)

	# Direction towards mouse
	var direction = (target_position - global_position).normalized()

	# Apply impulse to ball
	ball.apply_impulse(direction * power)

func _draw():
	# Draw aiming line only while charging
	var t = charge_time / max_charge_time
	var color = Color(1.0, 1.0 - t, 1.0 - t)	# Turns red at full charge
	draw_line(Vector2.ZERO, aim_direction * 100, color, 3.0)
