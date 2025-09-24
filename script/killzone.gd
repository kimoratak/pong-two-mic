extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
<<<<<<< HEAD
		get_tree().paused = true
		$"../UI/GameOver".show()
=======
		get_tree().reload_current_scene()
>>>>>>> origin/feature/level-1
	
