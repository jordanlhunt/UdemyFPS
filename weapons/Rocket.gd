extends KinematicBody
var explosion = preload("res://weapons/Explosion.tscn")
var speed = 30
var impact_Damage = 20
var isExploded = false


func _ready():
	hide()


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
			collider.TakeDamage(impact_Damage, -global_transform.basis.z)
		Explode()


func Explode():
	if isExploded:
		return
	isExploded = true
	speed = 0
	$CollisionShape.disabled = true
	var explosionInstance = explosion.instance()
	get_tree().get_root().add_child(explosionInstance)
	explosionInstance.global_transform.origin = global_transform.origin
	explosionInstance.Explode()
	$SmokeTrail.emitting = false
	$Graphics.hide()
	$FreeAfterImpactTimer.start()
