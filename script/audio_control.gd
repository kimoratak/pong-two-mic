extends HSlider

@export var audio_bus_name:String
var audio_bus_id
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_value_changed(value: float) -> void:
	var df = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, value)
