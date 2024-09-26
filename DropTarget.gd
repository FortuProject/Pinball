extends Node2D

@export var launch_force: float = 600.0  # Force applied to the ball
@export var cooldown_time: float = 0.1  # Cooldown time in seconds (set to 3 seconds)

var ball: RigidBody2D = null  # Placeholder for the ball
var can_launch: bool = true  # Whether the ball can be launched
var cooldown_timer: Timer 

@export var sprite_node_path: NodePath  # Path to Sprite2D node
@export var area_node_path: NodePath    # Path to Area2D node

var sprite: Sprite2D
var area: Area2D
var counter: int = 0  # Initialize counter to 0

@export var sfx_path: NodePath  # Path to the AudioStreamPlayer node

var sfx: AudioStreamPlayer
var sfx_played = false  # To track if SFX has been played

func play_sound():
	if sfx:
		sfx.play()

@onready var game_instance = get_node("../../Control") 
# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the sfx variable
	if sfx_path:
		sfx = get_node(sfx_path) as AudioStreamPlayer
		if not sfx:
			print("Warning: AudioStreamPlayer not found at path: ", sfx_path)
	else:
		print("Warning: NodePath for AudioStreamPlayer not assigned!")	# Create and configure the timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene tree

	# Get the nodes
	sprite = get_node(sprite_node_path) as Sprite2D
	area = get_node(area_node_path) as Area2D

	# Debugging: Print out what is actually retrieved
	if sprite:
		print("Sprite node found:", sprite)
	else:
		print("Error: Sprite2D not found at path:", sprite_node_path)

	if area:
		print("Area2D node found:", area)
		# Connect the signal for when a body enters the Area2D
		area.body_entered.connect(Callable(self, "_on_body_entered"))
	else:
		print("Error: Area2D not found at path:", area_node_path)


# Called when a body enters the Area2D
func _on_body_entered(body):
	# Only handle the collision if the cooldown is not active
	if can_launch and body.name == "Pinball":
		counter += 1
		print("Collision count:", counter)
		if game_instance:
			game_instance.add_to_score(200)  # Adds 10 to the current score
			print("Score updated from another script!")
		else:
			print("Game instance not found!")
		
		
		# First hit: Apply bounce
		if counter == 1:
			_on_Spring_body_entered(body)
		# Second hit: Hide the target
			if game_instance:
				game_instance.add_to_score(300)  # Adds 10 to the current score
				print("Score updated from another script!")
			else:
				print("Game instance not found!")
		
		elif counter >= 2:
			hide_target()
		
		# Start cooldown to prevent immediate re-launch and counter incrementing too fast
		can_launch = false
		cooldown_timer.start()

# Function to handle bouncing the pinball
func _on_Spring_body_entered(body):
	if body is RigidBody2D:
		ball = body  # Set the ball to be launched
		
		# Get the opposite of the current velocity (to launch in the opposite direction)
		var direction = -ball.linear_velocity.normalized()

		# Apply an impulse to the ball in the opposite direction of its velocity
		ball.apply_impulse(direction * launch_force)  
		
		print("Ball launched with force:", launch_force)

# Function to hide the sprite and collision shape
func hide_target():
	if sprite and area:
		sprite.visible = false
		area.monitoring = false  # Disable the Area2D for future collisions
		print("Drop target hidden")
		counter = 0  # Reset the counter after hiding the target
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
	else:
		print("Error: Unable to hide target. Sprite or Area is null.")

# Function to show the sprite and collision shape (if needed)
func show_target():
	if sprite and area:
		sprite.visible = true
		area.monitoring = true  # Re-enable the Area2D for collisions
		print("Drop target shown")
		counter = 0  # Reset the counter when the target is shown again

# Cooldown handler to allow launching and counter incrementing again
func _on_cooldown_timeout():
	can_launch = true  # Allow launching again after cooldown
	print("Cooldown finished, can launch again")
