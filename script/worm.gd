extends Area2D

var health := 2
var direction_x := 1
@export var speed := 50
@export var score_value: int = 10
@onready var death_sound = $AudioStreamPlayer2D

func _on_area_entered(area):
	health -= 1
	area.queue_free()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.3)
	$AudioStreamPlayer2D.play()
	
func _process(delta):
	check_death()
	position.x += speed * direction_x * delta
	
func check_death():
	if health <= 0:
		die()


func die():
	# ปิดการชนเพื่อไม่ให้รับความเสียหายเพิ่ม
	
	speed = 0 # หยุดการเคลื่อนที่
	death_sound.play()
	await death_sound.finished # รอให้เสียงตายเล่นจบ
	print("ENEMY: กำลังจะส่ง Signal died พร้อมคะแนน:", score_value)
	ScoreManager.add_score(score_value)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if 'get_damage' in body:
		body.get_damage(20)


func _on_border_area_body_entered(_body):
	direction_x *= -1
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h


func _on_right_cliff_area_body_exited(_body):
	direction_x *= -1
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h

func _on_left_cliff_area_body_exited(_body):
	direction_x *= -1
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
