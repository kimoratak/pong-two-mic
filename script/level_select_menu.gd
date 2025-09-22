extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_back_menu_pressed() -> void:
	$".".hide()
	$"../VBoxContainer".show()
	$"../Label".show()



func _on_go_to_level1_pressed() -> void:
	get_tree().change_scene_to_file("res://sence/level_1.tscn")


func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://sence/level_2.tscn")


func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://sence/level_3.tscn")



func _on_texture_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://sence/level_4.tscn")
