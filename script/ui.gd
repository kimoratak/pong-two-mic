extends CanvasLayer

# --- ประกาศตัวแปร Node ทั้งหมดไว้ด้านบน ---
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy = get_tree().get_first_node_in_group("enemy")
@onready var score_label = $MarginContainer2/HBoxContainer/level2
@onready var level_label = $MarginContainer2/HBoxContainer/level1
@onready var health_bar = $MarginContainer/ProgressBar
@onready var paused_menu = $PausedGame
@onready var level_complete = $LevelComplete
@onready var game_over = $GameOver

func _ready() -> void:
	# ซ่อน UI ทั้งหมดที่ยังไม่ต้องการแสดง
	$".".show()
	paused_menu.hide()
	game_over.hide()
	level_complete.hide()

	# --- การเชื่อมต่อ Signal ทั้งหมด ---
	# 1. เชื่อมต่อกับ ScoreManager เพื่ออัปเดตคะแนน
	if ScoreManager:
		ScoreManager.score_updated.connect(on_score_updated)

	get_tree().paused = false
	
	# แสดงผล Level ปัจจุบัน
	var current_scene_path = get_tree().current_scene.scene_file_path
	var level_number = _get_level_number_from_path(current_scene_path)
	if level_number > 0:
		level_label.text = "Level " + str(level_number)
	else:
		level_label.text = "Main Menu"

	score_label.text = "Score: 0"

# เพิ่ม: ฟังก์ชันสำหรับดักจับ Input เช่นการกดปุ่ม Esc เพื่อหยุดเกม
func _unhandled_input(event: InputEvent) -> void:
	# ตรวจสอบว่าไม่มี UI ใดๆ แสดงอยู่ และกดปุ่ม ui_cancel (ปกติคือ Esc)
	if event.is_action_pressed("ui_cancel") and not game_over.visible and not level_complete.visible:
		# สลับสถานะ paused ของเกม และการแสดงผลของเมนู
		get_tree().paused = not get_tree().paused
		paused_menu.visible = get_tree().paused

func _process(delta: float) -> void:
	if is_instance_valid(player):
		health_bar.value = player.health
	on_score_updated(ScoreManager.current_score)
	$LevelComplete/VBoxContainer/MarginContainer2/Label2.text = "score " + str(ScoreManager.current_score)
	

# --- ฟังก์ชันที่รอรับ Signal ต่างๆ ---
func on_score_updated(new_score: int):
	score_label.text = "Score: " + str(new_score)
# เพิ่ม: ฟังก์ชันนี้จะทำงานเมื่อได้รับ signal 'died' จาก Player
func _on_player_died():
	game_over.show()
	# อาจจะรอสักครู่ก่อนหยุดเกมเพื่อให้เห็นฉากตาย
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = true

# เพิ่ม: ฟังก์ชันนี้เอาไว้เชื่อมต่อกับ signal 'level_completed' จากด่าน
func _on_level_completed():
	level_complete.show()
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = true


# --- ฟังก์ชันของปุ่มต่างๆ (แก้ไขแล้ว) ---
func _on_goto_main_menu_pressed() -> void:
	# แก้ไข: ต้องยกเลิกการหยุดเกมก่อนเปลี่ยนซีนเสมอ
	get_tree().paused = false
	# แก้ไข: path ที่ถูกต้อง "scene"
	get_tree().change_scene_to_file("res://sence/main_menu.tscn")

func _on_reset_level_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	ScoreManager.reset_score()

func _on_next_level_pressed() -> void:
	get_tree().paused = false
	var current_scene_path = get_tree().current_scene.scene_file_path
	var current_level_num = _get_level_number_from_path(current_scene_path)
	
	if current_level_num > 0:
		var next_level_num = current_level_num + 1
		# แก้ไข: path ที่ถูกต้อง "scene"
		var next_level_path = "res://sence/level_" + str(next_level_num) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
	ScoreManager.reset_score()

func _on_play_game_pressed() -> void:
	get_tree().paused = false
	paused_menu.hide()

# ฟังก์ชันดึงหมายเลขด่าน (ไม่ต้องแก้ไข)
func _get_level_number_from_path(scene_path: String) -> int:
	var file_name = scene_path.get_file()
	var base_name = file_name.get_basename()
	if base_name.begins_with("level_"):
		var number_string = base_name.erase(0, 6)
		if number_string.is_valid_int():
			return number_string.to_int()
	return 0
