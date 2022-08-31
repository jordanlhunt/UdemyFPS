extends Area
var bodiesToExclude = []
var damage = 1


func SetDamage(_damage: int):
	damage = _damage


func SetBodiesToExclude(_bodiesToExclude: Array):
	bodiesToExclude = _bodiesToExclude


func Fire():
	for body in get_overlapping_bodies():
		if body.has_method("TakeDamage") and !body in bodiesToExclude:
			print("[DamageArea.gd] - Fire() - Triggered")
			body.TakeDamage(
				damage, global_transform.origin.direction_to(body.global_transform.origin)
			)
