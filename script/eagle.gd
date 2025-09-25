extends Area2D

@export var health := 3
@export var score_value: int = 100
@export var marker1: Marker2D
@export var marker2: Marker2D
@export var speed = 25
@export var notice_radius := 80

@onready var target = marker1
@onready var player = get_tree().get_first_node_in_group('player')
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_sound = $AudioStreamPlayer2D

var forward := true
# ⭐️ เพิ่มตัวแปรสำหรับคำนวณ Velocity ⭐️
var velocity := Vector2.ZERO

func _ready():
	if marker1:
		position = marker1.position

func _process(delta):
	if health <= 0:
		return

	# เก็บตำแหน่งเก่าไว้ก่อนที่จะเคลื่อนที่
	var old_position = position

	if not is_instance_valid(player):
		target = marker2 if forward else marker1
	else:
		get_target()

	if is_instance_valid(target):
		position += (target.position - position).normalized() * speed * delta
	
	# ⭐️ คำนวณ Velocity จากตำแหน่งใหม่และเก่า ⭐️
	# Velocity คือ (ตำแหน่งปัจจุบัน - ตำแหน่งเก่า) / เวลา
	# เราใช้ delta ซึ่งก็คือเวลาที่ผ่านไปในเฟรมนั้น
	velocity = (position - old_position) / delta

	# เรียกใช้ flip_logic (ซึ่งตอนนี้จะใช้ velocity)
	flip_logic()

# ⭐️⭐️⭐️ แก้ไข flip_logic อีกครั้ง ⭐️⭐️⭐️
func flip_logic():
	# ไม่ต้องเช็คเป้าหมายอีกต่อไป แต่เช็คจาก "ทิศทางการเคลื่อนที่จริง"
	if velocity.x != 0:
		# ถ้าความเร็วแนวนอนเป็นลบ (เคลื่อนที่ไปทางซ้าย) -> กลับด้าน
		# ถ้าความเร็วแนวนอนเป็นบวก (เคลื่อนที่ไปทางขวา) -> ไม่กลับด้าน
		animated_sprite.flip_h = velocity.x < 0

func get_target():
	if (forward and position.distance_to(marker2.position) < 10) or \
	   (not forward and position.distance_to(marker1.position) < 10):
		forward = not forward
		
	if is_instance_valid(player) and position.distance_to(player.position) < notice_radius:
		target = player
	else:
		target = marker2 if forward else marker1

# --- ฟังก์ชันอื่นๆ เหมือนเดิม ไม่ต้องแก้ไข ---
func take_damage(amount: int):
	if health <= 0: return
	health -= amount
	var tween = create_tween()
	tween.tween_property(animated_sprite, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property(animated_sprite, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	if health <= 0:
		die()

func die():
	$CollisionShape2D.set_deferred("disabled", true)
	speed = 0
	death_sound.play()
	await death_sound.finished
	ScoreManager.add_score(score_value)
	queue_free()

func _on_area_entered(area):
	take_damage(1)
	area.queue_free()
	
func _on_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(10)
