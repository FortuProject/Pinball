extends RigidBody2D

@export var gravity: float = 0.5  # Custom gravity value
@export var max_speed: float = 3000.0  # Maximum speed
@export var reset_position: Vector2 = Vector2(100, 200)  # Fallback position if no target polygon
@export var stuck_threshold: float = 30.0  # Time in seconds the ball has to be stuck before moving
var stuck_timer: float = 30.0  # Timer to track how long the ball has been stuck

@export var check_interval: float = 1.0  # Interval for checking if the ball is stuck
@export var target_polygon: CollisionPolygon2D  # Reference to the CollisionPolygon2D node

var timer: Timer

func _ready():
	# Create and configure the timer
	timer = Timer.new()
	timer.wait_time = check_interval  # Set to check interval (default 1 second)
	timer.one_shot = false  # Repeat the timer
	timer.autostart = true  # Start the timer automatically
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)  # Add the timer to the scene tree

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Apply custom gravity by adjusting the linear velocity in the y direction
	var velocity = state.linear_velocity
	velocity.y += gravity  # Apply gravity to the velocity

	# Clamp the speed to the maximum value
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	state.linear_velocity = velocity  # Update the rigid body's velocity

func _on_timer_timeout():
	# Check if the ball is stuck (velocity is very low)
	#if linear_velocity.length() < stuck_threshold:
	#	print("Ball is stuck, finding closest point on polygon.")
	#else:
		pass 
		#print("Ball is moving normally. Position:", global_position, "Velocity:", linear_velocity)


