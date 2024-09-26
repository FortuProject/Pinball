extends Control

# Declare the nodes and variables
@onready var score_label = $VBoxContainer/Label
@onready var ball_num = $VBoxContainer/BallsLeft
@export var game_stats: GameStats = preload("res://Scripts/game_stats.tres")  # Load the .tres file
var counter = 0  # Move the counter outside of the function so its value persists
var score: int = 0
var highscore: int = 0

signal score_changed(new_score)  # Signal for score changes
signal ball_drained(new_ball)


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
	if score_label:
		update_score_label(score)
		# Connect the score_changed signal to _on_score_changed and multiball methods
		score_changed.connect(_on_score_changed)
		score_changed.connect(multiball)  # Also connect multiball to score_changed
	else:
		print("Score label not found!")
		

func _on_score_changed(new_score: int) -> void:
	update_score_label(new_score)

func update_score_label(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: " + str(new_score)
	else:
		print("Score label not found!")

# Method to update the score and emit signal
func set_score(new_score: int) -> void:
	score = new_score
	score_changed.emit(score)

# Method to add to the score and emit signal
func add_to_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

# Check if the score is high enough to activate multiball
func multiball(new_score: int) -> void:
	if new_score >= 1500 and counter == 0:
		var ball_scene = load("res://Scenes/Pinball2.tscn")  # Load the Pinball scene
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
		if ball_scene:  # Check if the scene is loaded correctly
			var new_ball = ball_scene.instantiate()  # Instantiate the new ball
			
			# Get the root node, which is represented by "."
			var root_node = get_tree().root  # Root of the scene tree
			
			if root_node:  # Ensure root node exists
				root_node.add_child(new_ball)  # Add the new ball to the root
				print("Multiball activated and ball added to root!")
				counter = 1  # Ensure multiball is only triggered once
			else:
				print("Root node not found!")
		else:
			print("Failed to load Pinball2.tscn scene")
	if new_score >= 3000 and counter == 1:
		var ball_scene = load("res://Scenes/Pinball2.tscn")  # Load the Pinball scene
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
		if ball_scene:  # Check if the scene is loaded correctly
			var new_ball = ball_scene.instantiate()  # Instantiate the new ball
			# Get the root node, which is represented by "."
			var root_node = get_tree().root  # Root of the scene tree
			
			if root_node:  # Ensure root node exists
				root_node.add_child(new_ball)  # Add the new ball to the root
				print("Multiball activated and ball added to root!")
				counter = 2  # Ensure multiball is only triggered once
			else:
				print("Root node not found!")
		else:
			print("Failed to load Pinball2.tscn scene")
	if new_score >= 4500 and counter == 2:
		var ball_scene = load("res://Scenes/Pinball2.tscn")  # Load the Pinball scene
		if not sfx_played:  # Play SFX once
			play_sound()
			sfx_played = false
		if ball_scene:  # Check if the scene is loaded correctly
			var new_ball = ball_scene.instantiate()  # Instantiate the new ball
			
			# Get the root node, which is represented by "."
			var root_node = get_tree().root  # Root of the scene tree
			
			if root_node:  # Ensure root node exists
				root_node.add_child(new_ball)  # Add the new ball to the root
				print("Multiball activated and ball added to root!")
				counter = 3  # Ensure multiball is only triggered once
			else:
				print("Root node not found!")
		else:
			print("Failed to load Pinball2.tscn scene")
