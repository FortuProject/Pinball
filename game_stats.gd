class_name GameStats
extends Resource

@export var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)
		check_highscore()

@export var highscore: int = 0

signal score_changed(new_score)  # Signal for score changes

# Function to check and update the highscore
func check_highscore() -> void:
	if score > highscore:
		highscore = score
		print("New highscore:", highscore)
