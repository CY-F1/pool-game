extends Node2D

@export var ball_scene = preload("res://ball.tscn")
@export var min_power: float = 200
@export var max_power: float = 1000
@export var max_charge_time: float = 2.0  # seconds to reach max power


var charging: bool = false
var charge_time: float = 0.0
var aim_direction: Vector2 = Vector2.ZERO

func _process(delta):
	if charging:
		# Increase charge over time
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)



func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start charging
				charging = true
				charge_time = 0.0
			else:
				# Release: shoot
				if charging:
					shoot_ball(event.position)
					charging = false
					charge_time = 0.0

	if event is InputEventMouseMotion:
		# Update aim direction
		aim_direction = (event.position - global_position).normalized()

func shoot_ball(target_position: Vector2):
	var ball = ball_scene.instantiate()
	ball.global_position = global_position
	get_parent().add_child(ball)

	# Calculate power based on charge time
	var t = charge_time / max_charge_time
	var power = lerp(min_power, max_power, t)

	# Direction towards mouse
	var direction = (target_position - global_position).normalized()

	# Apply impulse to the ball
	ball.apply_impulse(direction * power)

	# Optionally: start ball animation or size updates
	if "animate_merge" in ball:
		ball.call_deferred("animate_merge")

func _draw():
	# Draw aiming line for feedback
	draw_line(Vector2.ZERO, aim_direction * 100, Color.RED, 10)
