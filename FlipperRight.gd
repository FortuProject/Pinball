extends CharacterBody2D

@export var flipper_speed: float = 500.0  # Speed at which the flipper rotates
@export var max_rotation: float = 40.0  # Maximum rotation angle in degrees
@export var return_speed: float = 300.0  # Speed at which the flipper returns to neutral
@export var flipper_force: float = 900.0  # Force applied to the ball when the flipper hits it

@export var sfx_path: NodePath  # Path to the AudioStreamPlayer node

var sfx: AudioStreamPlayer
var rotation_direction = 0.0
var ball: RigidBody2D = null  # The ball to be affected by the flipper

var sfx_played = false  # To track if SFX has been played

func _ready():
	# Initialize the sfx variable
	if sfx_path:
		sfx = get_node(sfx_path) as AudioStreamPlayer
		if not sfx:
			print("Warning: AudioStreamPlayer not found at path: ", sfx_path)
	else:
		print("Warning: NodePath for AudioStreamPlayer not assigned!")

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		rotation_direction = flipper_speed * delta  # Rotate upwards
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
	else:
		# Return to neutral position
		if rotation > 0:
			rotation_direction = -return_speed * delta
		elif rotation < 0:
			rotation_direction = return_speed * delta
		else:
			rotation_direction = 0.0  # Stay still when at neutral

	# Apply rotation
	if rotation_direction != 0:
		rotate(rotation_direction)
		rotation = clamp(rotation, deg_to_rad(0), deg_to_rad(max_rotation))  # Keep within the max range

	# Apply force to the ball if it's detected
	if ball and rotation_direction != 0:
		apply_flipper_force_to_ball()

func apply_flipper_force_to_ball():
	if ball:
		# Calculate the direction of the impulse based on the flipper's rotation
		var force_direction = -Vector2.UP.rotated(rotation)  # Adjust based on your flipper rotation direction
		ball.apply_impulse(force_direction * flipper_force)  # Apply the force
		print("Flipper force applied!")

# Inside the flipper script

func _on_Flipper_body_entered(body):
	if body is RigidBody2D:
		ball = body  # Set the ball to be affected by the flipper
		print("Ball entered flipper area!")


func play_sound():
	if sfx:
		sfx.play()
