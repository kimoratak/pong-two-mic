extends Area2D



@export var health := 3
@export var score_value: int = 100
@export var marker1: Marker2D
@export var marker2: Marker2D
@export var speed = 25
@export var notice_radius := 80

@onready var target = marker1 # เริ่มต้นให้มีเป้าหมายเลย
@onready var player = get_tree().get_first_node_in_group('player')
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_sound = $AudioStreamPlayer2D

var forward := true

func _ready():
	# ตรวจสอบว่า marker ถูกกำหนดค่าแล้วหรือยัง
	if marker1:
		position = marker1.position

func _process(delta):
	# หยุดการทำงานทั้งหมดถ้า health <= 0
	if health <= 0:
		return

	# ตรวจสอบว่า player ยังอยู่ในซีน
	if not is_instance_valid(player):
		# ถ้าผู้เล่นตายหรือออกจากซีนไปแล้ว ก็อาจจะให้กลับไปลาดตระเวน
		target = marker2 if forward else marker1
	else:
		get_target()

	position += (target.position - position).normalized() * speed * delta
	flip_logic()
	
func flip_logic():
	if is_instance_valid(player) and position.distance_to(player.position) < notice_radius:
		animated_sprite.flip_h = position.x > player.position.x
	else:
		animated_sprite.flip_h = not forward

func get_target():
	# ตรรกะการสลับเป้าหมายลาดตระเวน
	if (forward and position.distance_to(marker2.position) < 10) or \
	   (not forward and position.distance_to(marker1.position) < 10):
		forward = not forward
		
	# เลือกเป้าหมาย
	if position.distance_to(player.position) < notice_radius:
		target = player
	else:
		target = marker2 if forward else marker1

# ฟังก์ชันรับความเสียหาย (เราจะสร้างฟังก์ชันนี้ขึ้นมาเพื่อรวมการทำงาน)
func take_damage(amount: int):
	# ป้องกันไม่ให้โค้ดทำงานซ้ำซ้อนถ้าตายไปแล้ว
	if health <= 0:
		return

	health -= amount
	
	# สร้างเอฟเฟกต์กระพริบ
	var tween = create_tween()
	tween.tween_property(animated_sprite, "material:shader_parameter/amount", 1.0, 0.0)
	tween.tween_property(animated_sprite, "material:shader_parameter/amount", 0.0, 0.1).set_delay(0.2)
	
	# ตรวจสอบการตายทันทีที่ได้รับความเสียหาย
	if health <= 0:
		die()

# ฟังก์ชันสำหรับจัดการตอนตายโดยเฉพาะ
func die():
	# ปิดการชนเพื่อไม่ให้รับความเสียหายเพิ่ม
	$CollisionShape2D.set_deferred("disabled", true)
	speed = 0 # หยุดการเคลื่อนที่
	death_sound.play()
	await death_sound.finished # รอให้เสียงตายเล่นจบ
	print("ENEMY: กำลังจะส่ง Signal died พร้อมคะแนน:", score_value)
	ScoreManager.add_score(score_value)
	queue_free()

func _on_area_entered(area):
	# เรียกใช้ฟังก์ชันรับความเสียหายเมื่อโดนกระสุน (สมมติว่ากระสุนคือ area)
	take_damage(1)
	area.queue_free()
	
func _on_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(10)
