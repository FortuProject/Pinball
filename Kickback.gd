extends Area2D

@export var launch_force: float = 0.0  # Force applied to the ball
var ball: RigidBody2D = null  # Placeholder for the ball
@export var drop_target_node_path: NodePath  # Path to DropTarget node
@onready var game_instance = get_node("../Control") 
var drop_targets: Array[CharacterBody2D] = []

@export var sfx_path: NodePath  # Path to the AudioStreamPlayer node

var sfx: AudioStreamPlayer
var sfx_played = false  # To track if SFX has been played

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
	# Retrieve multiple DropTarget nodes and store them in the array
	var drop_target1 = get_node("../DropTarget") as CharacterBody2D
	var drop_target2 = get_node("../DropTarget2") as CharacterBody2D
	var drop_target3 = get_node("../DropTarget3") as CharacterBody2D
	var drop_target4 = get_node("../DropTarget4") as CharacterBody2D
	
	# Store each retrieved node in the array
	if drop_target1:
		drop_targets.append(drop_target1)
	if drop_target2:
		drop_targets.append(drop_target2)
	if drop_target3:
		drop_targets.append(drop_target3)
	if drop_target4:
		drop_targets.append(drop_target4)

	# Debug: Print the retrieved nodes
	for target in drop_targets:
		print("Retrieved DropTarget:", target)
	# Connect the signal for when a body enters the Area2D
	self.body_entered.connect(_on_Spring_body_entered)
	print("Signal connected")


func _process(delta):
	pass

func _on_Spring_body_entered(body):
	if body is RigidBody2D:
		ball = body
		print("Ball entered the kickback!")
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
		if game_instance:
			game_instance.add_to_score(500)  # Adds 10 to the current score
			print("Score updated from another script!")
		else:
			print("Game instance not found!")
		# Print the ball's current position before teleporting it
		print("Ball position before reset:", ball.global_position)

		# Reset ball's position and velocity
		ball.sleeping = true
		ball.global_position = Vector2(185, 380)
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0

		# Print the ball's position after teleporting it to the spring
		print("Ball position after reset:", ball.global_position)

		# Reactivate ball after a delay
		await get_tree().create_timer(3).timeout

		if drop_targets:
			for target in drop_targets:
				target.show_target()  # Ensure drop_target is not null before calling the method
		else:
			print("Error: drop_target is null, cannot call show_target().")
		ball.sleeping = false
		print("Ball re-enabled.")
