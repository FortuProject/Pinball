extends Area2D

@export var spin_factor: float = 0.1  # Factor to control how much spin is applied
var angular_velocity: float = 0.0  # Current angular velocity of the spinner
var angular_damping: float = 0.99  # Damping to gradually slow down the spin
@onready var game_instance = get_node("../Control") 
@export var sfx_path: NodePath  # Path to the AudioStreamPlayer node

var sfx: AudioStreamPlayer
var sfx_played = false  # To track if SFX has been played

# Called every frame
func _physics_process(delta):
	# Rotate the Sprite2D based on the angular velocity
	if $Sprite2D:
		$Sprite2D.rotation += angular_velocity * delta

	# Gradually reduce the spin (damping)
	angular_velocity *= angular_damping

func _on_body_entered(body):
	# Ensure the colliding object is a RigidBody2D (like the pinball)
	if body is RigidBody2D:
		# Get the speed of the pinball (length of the velocity vector)
		var pinball_speed = body.linear_velocity.length()
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
		# Calculate the spin based on the pinball's speed and spin factor
		angular_velocity += pinball_speed * spin_factor
		if game_instance:
			game_instance.add_to_score(10*spin_factor)  # Adds 10 to the current score
			print("Score updated from another script!")
		else:
			print("Game instance not found!")
		print("Pinball hit the spinner with speed: ", pinball_speed)


func play_sound():
	if sfx:
		sfx.play()

func _ready():
	# Initialize the sfx variable
	if sfx_path:
		sfx = get_node(sfx_path) as AudioStreamPlayer
		if not sfx:
			print("Warning: AudioStreamPlayer not found at path: ", sfx_path)
	else:
		print("Warning: NodePath for AudioStreamPlayer not assigned!")
	# Connect the body_entered signal to detect when the pinball enters the area
	self.body_entered.connect(_on_body_entered)

func _on_sprite_2d_ready():
	pass # Replace with function body.
