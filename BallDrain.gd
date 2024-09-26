extends Area2D

@export var launch_force: float = 900.0  # Force applied to the ball
var ball: RigidBody2D = null  # Placeholder for the ball

# Counter for the total number of balls left (starts at 3)
var ball_counter: int = 3

# Reference to the original ball (assigned when the game starts)
var original_ball: RigidBody2D = null

# List to store the instantiated balls
var instantiated_balls: Array = []

# Reference to the label that shows how many balls are left
@onready var ball_num: Label = $"../Control/VBoxContainer/BallsLeft" # Ensure this is correct and points to a Label node

func _ready():
	# Connect the signal for when a body enters the Area2D
	self.body_entered.connect(_on_Spring_body_entered)
	print("Signal connected")

	# Assuming the original ball is assigned or exists when the game starts
	original_ball = $"../Pinball"

	# Initialize the ball number label
	update_ball_num_label()

func _on_Spring_body_entered(body):
	# Check if the body that entered is a RigidBody2D
	if body is RigidBody2D:
		print("A ball entered the drain.")

		# Decrement ball counter when any ball hits the drain
		ball_counter -= 1
		print("Ball counter:", ball_counter)

		# Update the ball number label
		update_ball_num_label()

		# If the ball counter reaches 0, end the game
		if ball_counter <= 0:
			print("Game over! All balls lost.")
			# Handle game over logic here
			get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
			return

		# If an instantiated ball hits the drain, remove it
		if body != original_ball:
			print("An instantiated ball entered the drain. Queue free.")
			instantiated_balls.erase(body)
			body.queue_free()
			return

		# If the original ball hits the drain, reset its position
		print("Original ball entered the drain.")
		_reset_ball(body)

# Function to reset the ball's position and velocity
func _reset_ball(ball: RigidBody2D):
	print("Ball position before reset:", ball.global_position)

	# Reset the ball position and velocity
	ball.sleeping = true
	ball.global_position = Vector2(185, 380)  # Position of the spring
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

	# Print the ball's position after resetting to the spring
	print("Ball position after reset:", ball.global_position)

	# Reactivate ball after a short delay
	await get_tree().create_timer(0.1).timeout
	ball.sleeping = false
	print("Ball re-enabled.")

# Add function to track instantiated balls (e.g., when spawning new balls)
func add_instantiated_ball(new_ball: RigidBody2D) -> void:
	instantiated_balls.append(new_ball)
	ball_counter += 1  # Increment ball counter for each new ball
	print("New ball added. Ball counter:", ball_counter)
	update_ball_num_label()

# Function to update the ball number label
func update_ball_num_label() -> void:
	if ball_num:
		ball_num.text = "Balls Left: " + str(ball_counter)
		print("Label updated: Balls Left: " + str(ball_counter))
	else:
		print("Ball number label not found!")
