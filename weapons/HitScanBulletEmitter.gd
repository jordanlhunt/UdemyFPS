extends Spatial

# Preload the asset so I can instance it whenever I need to
var hitEffect = preload("res://effects/BulletHitEffect.tscn")

export var maximumHitDistance = 1000
var bodiesToExclude = []
var damage = 1


func SetDamage(_damage: int):
	damage = _damage


func SetBodiesToExclude(_bodiesToExclude: Array):
	bodiesToExclude = _bodiesToExclude


func Fire():
	var spaceState = get_world().get_direct_space_state()
	var originPosition = global_transform.origin
	var resultingHitData = spaceState.intersect_ray(
		originPosition,
		originPosition - global_transform.basis.z * maximumHitDistance,
		bodiesToExclude,
		1 + 4,
		true,
		true
	)
	if resultingHitData and resultingHitData.collider.has_method("TakeDamage"):
		resultingHitData.collider.TakeDamage(damage, resultingHitData.normal)
	elif resultingHitData:
		# If it doesn't hit something with a hurt method it must be a wall
		var hitEffectInstance = hitEffect.instance()
		get_tree().get_root().add_child(hitEffectInstance)
		hitEffectInstance.global_transform.origin = resultingHitData.position
		print("[HitScanBulletEmitter.gd] - Fire() - A bullet was fired")
		# Set normal
		if resultingHitData.normal.angle_to(Vector3.UP) < 0.00005:
			return
		if resultingHitData.normal.angle_to(Vector3.DOWN) < 0.00005:
			hitEffectInstance.rotate(Vector3.RIGHT, PI)
			return
		var y = resultingHitData.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)

		hitEffectInstance.global_transform.basis = Basis(x, y, z)
