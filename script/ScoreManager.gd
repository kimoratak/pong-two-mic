extends Node

# ตัวแปรสำหรับเก็บคะแนนปัจจุบัน
var current_score: int = 0

# Signal ที่จะถูกส่งออกไปเมื่อคะแนนมีการเปลี่ยนแปลง
# เพื่อให้ UI นำไปอัปเดตการแสดงผล
signal score_updated(new_score)

# ฟังก์ชันสำหรับเพิ่มคะแนน
func add_score(points: int):
	current_score += points
	print("ได้รับคะแนน: ", points, " | คะแนนรวม: ", current_score) # สำหรับ Debug
	# ส่ง Signal ออกไปพร้อมกับคะแนนใหม่
	score_updated.emit(current_score)

# ฟังก์ชันสำหรับรีเซ็ตคะแนน (เช่น เมื่อเริ่มเกมใหม่)
func reset_score():
	current_score = 0
	score_updated.emit(current_score)

# ฟังก์ชันสำหรับดึงค่าคะแนนปัจจุบัน (เผื่อต้องใช้)
func get_score() -> int:
	return current_score
