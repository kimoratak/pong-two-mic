extends Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



#go to next level 
func _on_body_entered(body: Node2D) -> void:
	print("next level")
	print(get_path())
	if body.is_in_group("player"):
		get_tree().paused = true
<<<<<<< HEAD
		$"../../UI/LevelComplete".show()
=======
		$"../Player/UI/LevelComplete".show()
>>>>>>> origin/feature/level-1
		#var currentlevel = get_tree().current_scene.scene_file_path
		#print(currentlevel)
		#var nextlevel = currentlevel.to_int() +1
		#print(nextlevel)
		#var nextlevelPath = "res://sence/level_" + str(nextlevel) +".tscn"
		#print(nextlevelPath)
		#get_tree().change_scene_to_file(nextlevelPath)
