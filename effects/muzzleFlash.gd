extends Spatial

export var flashTime = .07
var timer: Timer


func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flashTime
	timer.connect("timeout", self, "EndFlash")
	hide()


func Flash():
	timer.start()
	rotation.z = rand_range(0.0, 2 * PI)
	if self.get_parent().get_parent().name == "Shotgun":
		scale.x = rand_range(2.0, 3.5)
		scale.y = rand_range(2.0, 3.5)
	show()


func EndFlash():
	hide()
