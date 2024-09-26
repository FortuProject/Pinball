extends Area2D

@export var launch_force: float = 500.0  # Force applied to the ball
@export var cooldown_time: float = .01  # Cooldown time in seconds
@onready var game_instance = get_node("../../Control") 
var ball: RigidBody2D = null  # Placeholder for the ball
var can_launch: bool = true  # Whether the ball can be launched
var cooldown_timer: Timer 

func _ready():
	# Create and configure the timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene tree

	# Connect the signal for when a body enters the Area2D
	self.body_entered.connect(_on_Spring_body_entered)
	print("Signal connected")

func _process(delta):
	pass  # We will handle launching in _on_Spring_body_entered

func _on_Spring_body_entered(body):
	if body is RigidBody2D and can_launch:
		ball = body  # Set the ball to be launched
		if game_instance:
			game_instance.add_to_score(30)  # Adds 10 to the current score
			print("Score updated from another script!")
		else:
			print("Game instance not found!")
		# Get the opposite of the current velocity (to launch in the opposite direction)
		var direction = -ball.linear_velocity.normalized()

		# Apply an impulse to the ball in the opposite direction of its velocity
		ball.apply_impulse(direction * launch_force)  
		
		# Start cooldown to prevent immediate re-launch
		can_launch = false  
		cooldown_timer.start()

func _on_cooldown_timeout():
	can_launch = true  # Allow launching again after cooldown
