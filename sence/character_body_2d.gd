extends CharacterBody2D

## Movement & Physics 🏃
@export var speed := 180.0
@export var acceleration := 600.0
@export var friction := 800.0
@export var air_acceleration_multiplier := 0.7 # ทำให้ควบคุมกลางอากาศได้ช้ากว่าบนพื้นเล็กน้อย
@export var gravity_scale := 800.0

## Jumping Mechanics 🤸
@export var jump_velocity := -400.0
@export var max_jumps := 2
var jumps_used := 0

## Coyote Time 🐺
# (อย่าลืมเพิ่ม Timer ชื่อ "CoyoteTimer" ใน Scene)
@onready var coyote_timer := $Timers/CoyoteTimer
var was_on_floor := false

## Player State
var facing_right := true
var has_gun := false
var vulnerable := true
var health := 100

## Signals
signal shoot(pos: Vector2, direction: bool)

#-----------------------------------------------------------------------------

func _ready():
	$UI/LevelComplete.hide()
	$UI/GameOver.hide()
	$UI/PausedGame.hide()
	
	for child in $Fire.get_children():
		child.hide()

func _physics_process(delta: float):
	# 1. ใช้แรงโน้มถ่วง
	apply_gravity(delta)
	pase_game()
	reset_game()
	
	# 2. รับ Input และจัดการการกระโดด
	handle_jump_input()
	
	# 3. จัดการการเคลื่อนที่แนวนอน (พร้อม Air Resistance)
	handle_horizontal_movement(delta)

	# 4. อัปเดตการเคลื่อนที่
	move_and_slide()
	
	# 5. อัปเดตสถานะหลังการเคลื่อนที่ (สำหรับ Coyote Time และรีเซ็ตการกระโดด)
	update_after_move()

	# 6. อัปเดตภาพและเสียง
	get_facing_direction()
	get_animation()
	handle_shoot_input() # ย้ายการยิงมาไว้ตรงนี้เพื่อความเรียบร้อย
	
	# 7. เช็คสถานะเกม
	check_death()

#-----------------------------------------------------------------------------

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity_scale * delta

func handle_jump_input():
	# --- ตรรกะการกระโดดทั้งหมด (Coyote Time, Double Jump) ---
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped() or jumps_used < max_jumps):
		if not is_on_floor() and not coyote_timer.is_stopped():
			# ถ้าใช้ Coyote Jump ให้หยุด Timer ทันที
			coyote_timer.stop()
		
		velocity.y = jump_velocity
		jumps_used += 1
		$Sounds/JumpSound.play()

	# --- Variable Jump Height ---
	# ถ้าปล่อยปุ่มกระโดดตอนกำลังลอยขึ้น ให้กระโดดเตี้ยลง
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func handle_horizontal_movement(delta: float):
	var direction_x = Input.get_axis("left", "right")
	
	# --- Air Resistance (ความต้านทานอากาศ) ---
	var current_accel = acceleration
	if not is_on_floor():
		current_accel *= air_acceleration_multiplier
	
	if direction_x != 0:
		# ค่อยๆ เพิ่มความเร็วจนถึง speed สูงสุด
		velocity.x = move_toward(velocity.x, speed * direction_x, current_accel * delta)
	else:
		# ค่อยๆ ลดความเร็วจนหยุด (แรงเสียดทาน)
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func update_after_move():
	# รีเซ็ตการกระโดดเมื่อแตะพื้น
	if is_on_floor():
		jumps_used = 0
	
	# --- Coyote Time ---
	# ถ้าเฟรมที่แล้วอยู่บนพื้น แต่ตอนนี้ไม่อยู่ -> เริ่มนับเวลา Coyote Time
	if was_on_floor and not is_on_floor():
		$Timers/CoyoteTimer.start()
	
	was_on_floor = is_on_floor()

func handle_shoot_input():
	if Input.is_action_just_pressed("shoot") and $Timers/CooldownTimer.is_stopped() and has_gun:
		shoot.emit(global_position, facing_right)
		$Timers/CooldownTimer.start()
		$Timers/FireTimer.start()
		$Fire.get_child(int(facing_right)).show()
		$Sounds/fireSound.play()

func get_facing_direction():
	# หันหน้าตามทิศทางความเร็ว ไม่ใช่แค่ปุ่มที่กด
	if abs(velocity.x) > 10.0:
		facing_right = velocity.x > 0

func get_animation():
	var animation = 'idle'
	if not is_on_floor():
		animation = 'jump'
	elif abs(velocity.x) > 10.0:
		animation = 'walk'
	
	if has_gun:
		animation += '_gun'
	
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.flip_h = not facing_right

func check_death():
	if health <= 0:
		get_tree().paused = true
		$UI/GameOver.show()

func get_damage(amount):
	if vulnerable:
		health -= amount
		vulnerable = false
		$Timers/InvincibilityTimer.start()
		$Sounds/DamageSound.play()
		
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0.0)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 0.1)

# --- Signal Callbacks ---

func _on_cooldown_timer_timeout() -> void:
	# ไม่ต้องตั้ง can_shoot = true แล้ว เพราะเราเช็คจาก is_stopped() ของ Timer ได้เลย
	pass

func _on_fire_timer_timeout() -> void:
	for child in $Fire.get_children():
		child.hide()

func _on_invincibility_timer_timeout() -> void:
	vulnerable = true


func pase_game():
	if Input.is_action_just_pressed("PausedGame"):
		get_tree().paused =true
		$UI/PausedGame.show()
		
func reset_game():
	if Input.is_action_just_pressed("reset_level"):
		var currentlevel = get_tree().current_scene.scene_file_path
		var level = currentlevel.to_int()
		print(currentlevel)

		get_tree().change_scene_to_file(currentlevel)
