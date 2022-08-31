extends Spatial
var damage = 10
var bodiesToExclude = []
var fireballProjectile = preload("res://weapons/Fireball.tscn")


func SetDamage(_damage: int):
	damage = _damage


func SetBodiesToExclude(_bodiesToExclude: Array):
	bodiesToExclude = _bodiesToExclude


func Fire():
	var fireballProjectInstance = fireballProjectile.instance()
	fireballProjectInstance.SetBodiesToExclude(bodiesToExclude)
	get_tree().get_root().add_child(fireballProjectInstance)
	fireballProjectInstance.global_transform = global_transform
	fireballProjectInstance.impact_Damage = damage
