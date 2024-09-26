extends Area2D

@export var launch_force: float = 2500.0  # Force applied to the ball
@export var cooldown_time: float = 0.001  # Cooldown time in seconds
@export var shove_force: float = 10.0  # Force for shoving the ball
@onready var game_instance = get_node("../Control") 
var ball: RigidBody2D = null  # Placeholder for the ball
var can_launch: bool = true  # Whether the ball can be launched
var cooldown_timer: Timer 

@export var sfx_path: NodePath  # Path to the AudioStreamPlayer node

var sfx: AudioStreamPlayer
var sfx_played = false  # To track if SFX has been played

func _ready():
	get_tree().create_timer(3.0).timeout
	# Initialize the sfx variable
	if sfx_path:
		sfx = get_node(sfx_path) as AudioStreamPlayer
		if not sfx:
			print("Warning: AudioStreamPlayer not found at path: ", sfx_path)
	else:
		print("Warning: NodePath for AudioStreamPlayer not assigned!")
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
	# Check for spacebar press and if the cooldown has expired
	if Input.is_action_pressed("ui_accept"):
		if ball and can_launch:
			# Apply an impulse to the ball to launch it upwards
			ball.apply_impulse(Vector2(0, -launch_force))  # Launch the ball upwards
			ball = null  # Ensure impulse is applied only once
			can_launch = false  # Start the cooldown period
			cooldown_timer.start()  # Start the cooldown timer
			print("Launched ball!")
			if not sfx_played:  # Play SFX once
				play_sound()
				sfx_played = false
			if game_instance:
				game_instance.add_to_score(10)  # Adds 10 to the current score
				print("Score updated from another script!")
			else:
				print("Game instance not found!")
		elif ball:
			# Apply a shove if the spring cannot launch
			_shove_ball()

func _on_Spring_body_entered(body):
	if body is RigidBody2D:
		if not can_launch:
			print("Cannot launch due to cooldown.")
			return  # Ignore if cooldown is active
		ball = body  # Set the ball to be launched
		print("Ball entered spring area!")
		# Reset ball's position and velocity
		ball.position = Vector2(185, 380)
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		print("Ball reset to position and velocity.")

func _on_cooldown_timeout():
	can_launch = true  # Allow launching again after cooldown
	print("Cooldown expired, ready to launch again.")

func _shove_ball():
	if ball:
		# Calculate a random direction
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		# Apply an impulse to the ball in the random direction
		var impulse = random_direction * shove_force
		ball.apply_impulse(ball.position, impulse)
		
		print("Shove applied: Direction:", random_direction, "Impulse:", impulse)


func play_sound():
	if sfx:
		sfx.play()
