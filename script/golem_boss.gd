extends CharacterBody2D

# --- ตัวแปรที่ปรับค่าได้ ---
@export var health: int = 100
@export var speed: float = 50.0
@export var detection_range: float = 400.0

# --- สถานะของบอส (State Machine) ---
enum State {
	IDLE,       # รอการทำงาน
	CHASING,    # ไล่ตามผู้เล่น
	ATTACKING,  # โจมตี
	HURT,       # ได้รับความเสียหาย
	DEAD        # ตาย
}
var current_state: State = State.IDLE

# --- ตัวแปรอื่นๆ ---
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Node References ---
@onready var animated_sprite = $AnimatedSprite2D

# ฟังก์ชันนี้จะทำงานครั้งเดียวเมื่อเริ่มซีน
func _ready():
	# เปลี่ยนสถานะเริ่มต้นเป็น IDLE
	change_state(State.IDLE)

# ฟังก์ชันนี้จะทำงานทุกๆ เฟรมฟิสิกส์
func _physics_process(delta):
	# ใช้แรงโน้มถ่วงเสมอ (ยกเว้นตอนตาย)
	if current_state != State.DEAD:
		velocity.y += gravity * delta

	# ควบคุมพฤติกรรมตามสถานะปัจจุบัน
	match current_state:
		State.IDLE:
			# ตรรกะของสถานะ IDLE
			velocity.x = 0 # หยุดนิ่ง
			# ลองหาผู้เล่น
			find_player()
			if player != null:
				change_state(State.CHASING)

		State.CHASING:
			# ตรรกะของสถานะ CHASING
			if player == null:
				change_state(State.IDLE)
				return
			
			# เคลื่อนที่เข้าหาผู้เล่น
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			
			# พลิกตัว Golem ให้หันหน้าหาผู้เล่น
			if direction.x != 0:
				animated_sprite.flip_h = direction.x < 0

		State.ATTACKING:
			# ตรรกะของสถานะ ATTACKING
			velocity.x = 0 # หยุดตอนโจมตี
			pass

		State.HURT:
			# ตรรกะของสถานะ HURT
			pass

		State.DEAD:
			# ตรรกะของสถานะ DEAD
			velocity.x = 0
			pass

	# สั่งให้ CharacterBody2D เคลื่อนที่
	move_and_slide()

# --- ฟังก์ชันจัดการสถานะ ---
func change_state(new_state: State):
	current_state = new_state
	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.CHASING:
			animated_sprite.play("moving")
		State.ATTACKING:
			# การเลือกท่าโจมตีจะซับซ้อนกว่านี้
			animated_sprite.play("melee_attack") 
		State.HURT:
			# Asset นี้อาจไม่มีท่า hurt แต่ใส่ไว้เป็นโครง
			pass 
		State.DEAD:
			animated_sprite.play("defeated")
			# ปิดการชนทั้งหมด
			$CollisionShape2D.disabled = true 

# --- ฟังก์ชันอื่นๆ ---
func find_player():
	# วิธีการหาผู้เล่น (อาจต้องปรับปรุง)
	# เราจะใช้วิธีที่ดีกว่านี้ในเฟสถัดไป
	pass

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		change_state(State.DEAD)
	else:
		# อาจจะเพิ่มสถานะ HURT ที่นี่
		pass
