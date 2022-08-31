extends Spatial


func _ready():
	hide()
	EnableGibs()


func EnableGibs():
	show()
	for child in get_children():
		if child.has_method("Initialize"):
			child.Initialize()
		if "emitting" in child:
			child.emitting = true
