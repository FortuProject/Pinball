extends Area2D
@export var game_stats: GameStats
@export var launch_force: float = 700.0  # Force applied to the ball
@export var rotation_speed: float = 20.0  # Degrees per second for oscillation
@export var min_angle: float = deg_to_rad(-48.0)  # Minimum angle in radians
@export var max_angle: float = deg_to_rad(75.0)   # Maximum angle in radians
@export var cooldown_time: float = 0.1  # Cooldown time in seconds
@export var angular_velocity: float = 0.0  # Angular velocity applied to the ball upon launch
@export var speed: float = 700.0  # Speed of the ball after launch
@onready var game_instance = get_node("../../Control")  # Adjust the path according to your scene structure

var ball: RigidBody2D = null  # Ball loaded in the launcher
var is_ball_loaded: bool = false  # Whether a ball is currently loaded
var is_rotating_forward: bool = true  # To handle back-and-forth rotation
var cooldown_timer: Timer
var velocity: Vector2 = Vector2()  # Velocity vector for projectile motion

@onready var cannon_end = $CannonEnd  # Reference to the CannonEnd node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create and configure the timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene tree

	# Initialize rotation direction and speed
	is_rotating_forward = true

	# Connect the signal for when a body enters the Area2D
	body_entered.connect(_on_body_entered)

# Called every frame
func _process(delta: float):
	# Handle oscillating back-and-forth rotation
	if is_rotating_forward:
		rotation += rotation_speed * delta * deg_to_rad(1)
		if rotation >= max_angle:
			is_rotating_forward = false  # Switch to rotating backward
	else:
		rotation -= rotation_speed * delta * deg_to_rad(1)
		if rotation <= min_angle:
			is_rotating_forward = true  # Switch to rotating forward

	# Launch the ball if spacebar is pressed and the ball is loaded
	#if Input.is_action_just_pressed("ui_accept") and is_ball_loaded:
	#	launch_ball()

func _on_body_entered(body):
	# Ensure the body is a RigidBody2D (the ball)
	if body is RigidBody2D:
		ball = body  # Assign the body to the ball variable
		
		if game_instance:
			game_instance.add_to_score(100)  # Adds score
			print("Score updated from another script!")
		else:
			print("Game instance not found!")
		
		print("Body Entered:", body, "Type:", typeof(body), "Name:", body.name)

		# Get the opposite of the current velocity (to launch in the opposite direction)
		var launch_dir = Vector2(cos(rotation), sin(rotation)).normalized()

		# Ensure the direction is up and to the left
		if launch_dir.x < 0:
			launch_dir.x = -abs(launch_dir.x)
		else:
			launch_dir.x = abs(launch_dir.x)

		if launch_dir.y > 0:
			launch_dir.y = -abs(launch_dir.y)
		else:
			launch_dir.y = abs(launch_dir.y)

		var speed = 500  # Set the desired launch speed
		var angular_velocity = 10.0  # Set the desired angular velocity

		velocity = launch_dir * speed  # Set the ball's velocity

		# Check if the ball is valid before setting its velocity and angular velocity
		if ball:
			ball.linear_velocity = velocity  # Apply the velocity to the ball
			ball.angular_velocity = angular_velocity  # Set angular velocity
			ball.sleeping = false  # Wake the ball up
			ball.visible = true  # Ensure the ball is visible
		else:
			print("Ball is null. Cannot set velocity or angular velocity.")

		# Print the launch direction and other details for debugging
		print("Launch Direction:", launch_dir)
		print("Launch Speed:", speed)
		print("Launch Rotation:", rotation)

		# Ball is no longer in the launcher
		is_ball_loaded = false
		ball = null
		print("Ball launched with velocity:", velocity)
	else:
		print("Entered body is not a RigidBody2D")


# Function to handle cooldown timeout
func _on_cooldown_timeout():
	pass
