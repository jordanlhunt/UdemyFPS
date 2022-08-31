extends Area

# WHen monster is hit,

class_name Hitbox
export var isWeakSpot = false
export var criticalHitMultiplier = 1.5

signal TakeDamage


func TakeDamage(damage: int, direction: Vector3):
	if isWeakSpot:
		emit_signal("TakeDamage", damage * criticalHitMultiplier, direction)
	else:
		emit_signal("TakeDamage", damage, direction)
