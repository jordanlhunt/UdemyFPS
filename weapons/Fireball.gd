extends KinematicBody

var speed = 5
var impact_Damage = 20
var isExploded = false


func SetBodiesToExclude(bodiesToExclude: Array):
	for body in bodiesToExclude:
		add_collision_exception_with(body)


func _physics_process(delta):
	var isCollision: KinematicCollision = move_and_collide(
		-global_transform.basis.z * speed * delta
	)
	if isCollision:
		var collider = isCollision.collider
		if collider.has_method("TakeDamage"):
			print("[Fireball.gb] isCollision is ", isCollision)
			collider.TakeDamage(impact_Damage, -global_transform.basis.z)
		$Smoke.emitting = true
		speed = 0
		$Graphics.hide()
		$CollisionShape.disabled = true


func Show():
	pass  # Replace with function body.
