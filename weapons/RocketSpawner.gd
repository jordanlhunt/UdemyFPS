extends Spatial
var damage = 75
var bodiesToExclude = []
var rocketProjectile = preload("res://weapons/Rocket.tscn")


func SetDamage(_damage: int):
	damage = _damage


func SetBodiesToExclude(_bodiesToExclude: Array):
	bodiesToExclude = _bodiesToExclude


func Fire():
	var rocketProjectInstance = rocketProjectile.instance()
	rocketProjectInstance.SetBodiesToExclude(bodiesToExclude)
	get_tree().get_root().add_child(rocketProjectInstance)
	rocketProjectInstance.global_transform = global_transform
	rocketProjectInstance.impact_Damage = damage
