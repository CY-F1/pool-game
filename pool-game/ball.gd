class_name Ball
extends RigidBody2D

@export var size_level: int = 1
@onready var sprite: Sprite2D = $Balls
var merged_this_frame = false

# Called when ball is spawned
func _ready():
	add_to_group("balls")
	$scaled_stuff/Balls.frame = size_level -1
	#update_size()

# Handle merging with another ball
func try_merge(other: Ball):
	if other.size_level == size_level and merged_this_frame == false:
		other.queue_free()
		print("merging")
		var new_ball = preload("res://ball.tscn").instantiate()
		new_ball.size_level = size_level + 1
		new_ball.global_position = (global_position + other.global_position) / 2
		new_ball.linear_velocity = Vector2((self.linear_velocity.x+other.linear_velocity.x), (self.linear_velocity.y+other.linear_velocity.y))
		
		get_parent().add_child(new_ball)
		new_ball.animate_merge()
		## Defer adding the new ball
		#get_parent().call_deferred("add_child", new_ball)
#
		## Defer freeing both balls
		#call_deferred("queue_free")
		#other.call_deferred("queue_free")
#
		## Stop detecting collisions to prevent double merges
		#set_deferred("monitoring", false)
		#other.set_deferred("monitoring", false)
		merged_this_frame = true
		
		queue_free()
	

	
#func update_size():
	## Example: base size multiplied by size_level
	#animate_merge()
	#var scale_factor = 1.0 * size_level
	#$scaled_stuff.scale = Vector2(scale_factor, scale_factor)
	#$Ball_collision.scale = Vector2(scale_factor, scale_factor)
func animate_merge() -> void:
	
	# Target scale based on size_level
	var target_scale = Vector2(size_level, size_level)

	# Create tween
	var tween = create_tween()
	tween.tween_property($scaled_stuff, "scale", target_scale, 0.05)

	# Wait until tween finishes
	await tween.finished
	# After tween completes, ensure final scale is correct
	$scaled_stuff.scale = target_scale
	$Ball_collision.scale = target_scale
	
func _physics_process(delta):
	merged_this_frame = false  # reset every frame

func _on_area_2d_body_entered(body) -> void:
	if body is Ball and body != self:
		# Only merge if this ball's ID is smaller than the other
		if get_instance_id() < body.get_instance_id():
			try_merge(body)
	
