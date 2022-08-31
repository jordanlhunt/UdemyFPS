extends Spatial

onready var animationPlayer = $AnimationPlayer
onready var bulletEmitterBase: Spatial = $BulletEmitters
onready var bulletEmitters = $BulletEmitters.get_children()

export var isFullyAutomatic = false

var firePoint: Spatial
var bodiesToExclude: Array = []

# Bullet Damage
export var weaponDamage = 5
export var currentAmmo = 30
export var attackRate = .23
var attackTimer: Timer
var canAttack = true

signal fired
signal outOfAmmo


func _ready():
	attackTimer = Timer.new()
	attackTimer.wait_time = attackRate
	attackTimer.connect("timeout", self, "FinishAttack")
	attackTimer.one_shot = true
	add_child(attackTimer)


func Initialize(_firePoint: Spatial, _bodiesToExclude: Array):
	firePoint = _firePoint
	bodiesToExclude = _bodiesToExclude
	# Loop thorugh bullets and initalize them
	for bulletEmitter in bulletEmitters:
		bulletEmitter.SetDamage(weaponDamage)
		bulletEmitter.SetBodiesToExclude(bodiesToExclude)


# Check if the player just tapped the attack button is holding it down.
func Attack(attackInputJustPressed: bool, attackInputHeld: bool):
	if !canAttack:
		return
	if isFullyAutomatic and !attackInputHeld:
		return
	elif !isFullyAutomatic and !attackInputJustPressed:
		return
	if currentAmmo == 0:
		if attackInputJustPressed:
			emit_signal("outOfAmmo")
		return
	if currentAmmo > 0:
		currentAmmo -= 1

	var startTransform = bulletEmitterBase.global_transform
	bulletEmitterBase.global_transform = firePoint.global_transform
	for bulletEmitter in bulletEmitters:
		bulletEmitter.Fire()
	bulletEmitterBase.global_transform = startTransform
	animationPlayer.stop()
	animationPlayer.play("Attack")
	emit_signal("fired")
	canAttack = false
	attackTimer.start()


func FinishAttack():
	canAttack = true


func SetActive():
	show()
	$Crosshair.show()


func SetInactive():
	animationPlayer.play("Idle")
	hide()
	$Crosshair.hide()


func IsIdle():
	return !animationPlayer.is_playing() or animationPlayer.current_animation == "Idle"
