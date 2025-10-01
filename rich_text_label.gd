extends RichTextLabel


var mytext = "จบเกมแล้วดอยอยากจะบอกว่าดอยรักฝนนะ"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scroll_text(mytext)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func scroll_text(input_text:String)-> void:
	visible_characters = 0
	text = input_text

	for i in get_parsed_text():
		visible_characters +=1
		await get_tree().create_timer(0.1).timeout
		
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://sence/main_menu.tscn")
