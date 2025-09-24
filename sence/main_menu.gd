extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Options.hide()
	$Options/TextureButton.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_start_pressed() -> void:
	$VBoxContainer.hide()
	$Label.hide()
	$LevelSelectMenu.show()

	pass # Replace with function body.


func _on_setting_pressed() -> void:
	#print("setting")
	$VBoxContainer.hide()
	$Options.show()
	$Options/TextureButton.show()
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
	print("exit")
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	$Options.hide()
	$Options/TextureButton.hide()
	$VBoxContainer.show()
