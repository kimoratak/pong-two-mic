extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group('player')
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	get_tree().paused = false

 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var currentlevel = get_tree().current_scene.scene_file_path
	var level = currentlevel.to_int()
	$MarginContainer/ProgressBar.value = player.health
	$MarginContainer2/HBoxContainer/level1.text = "level " + str(level)



func _on_goto_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://sence/main_menu.tscn")


func _on_reset_level_pressed() -> void:
	var currentlevel = get_tree().current_scene.scene_file_path
	
	get_tree().change_scene_to_file(currentlevel)


func _on_next_level_pressed() -> void:
	var currentlevel = get_tree().current_scene.scene_file_path
	var nextlevel = currentlevel.to_int() +1
	var nextlevelPath = "res://sence/level_" + str(nextlevel) +".tscn"
	print(nextlevelPath)
	get_tree().change_scene_to_file(nextlevelPath)


func _on_play_game_pressed() -> void:
	get_tree().paused = false
	$PausedGame.hide()
	pass # Replace with function body.
