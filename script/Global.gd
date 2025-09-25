extends Node

var player_health: int = 100
var max_player_health: int = 100


func get_potion(potion_value: int):
	player_health += potion_value
	if player_health > max_player_health:
		player_health = max_player_health

func reset_player():
	player_health = max_player_health
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
