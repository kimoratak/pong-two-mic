extends Area2D

var potion_value: int = 30


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_body_entered(body: Node2D) -> void:
	#if body.group("plyer"):
	Global.get_potion(potion_value)
	queue_free()
	
