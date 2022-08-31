extends Spatial
signal dead
signal TakeDamage
signal healed
signal health_changed
signal gibbed
export var max_health = 100
export var gibb_at = -1
var current_health = 1
# External Reference to blood spary
var bloodSpary = preload("res://effects/BloodSpray.tscn")
# External Reference to gibs
var gibs = preload("res://effects/Gib/Gibs.tscn")


func _ready():
	initialize()


func initialize():
	current_health = max_health
	emit_signal("health_changed", current_health)
	print("Current Health: ", current_health)
	print("Max Health: ", max_health)


func TakeDamage(damage: int, direction_damage_came_from: Vector3):
	print("[HealthManager.gd] - TakeDamge() - The Entity Is Hit")
	SpawnBlood(direction_damage_came_from)
	if current_health <= 0:
		return
	current_health -= damage
	if current_health <= gibb_at:
		SpawnGibs()
		emit_signal("gibbed")
	if current_health <= 0:
		emit_signal("dead")
		print("Dead")
	else:
		emit_signal("TakeDamage")
	emit_signal("health_changed", current_health)
	print("Damage taken: ", damage, " | Current health: ", current_health)


func heal(healAmount: int):
	if current_health <= 0:
		return
	current_health += healAmount
	if current_health > max_health:
		current_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", current_health)


func SpawnBlood(directionOfDamageSource):
	var bloodSprayInstance = bloodSpary.instance()
	get_tree().get_root().add_child(bloodSprayInstance)
	# Current position of the object spawning blood
	bloodSprayInstance.global_transform.origin = global_transform.origin
	print("[HealthManager.gd] - SpawnBlood() - Blood has spawned")
	# Set normal
	if directionOfDamageSource.angle_to(Vector3.UP) < 0.00005:
		return
	if directionOfDamageSource.angle_to(Vector3.DOWN) < 0.00005:
		bloodSprayInstance.rotate(Vector3.RIGHT, PI)
		return
	var y = directionOfDamageSource
	var x = y.cross(Vector3.UP)
	var z = x.cross(y)

	bloodSprayInstance.global_transform.basis = Basis(x, y, z)


func SpawnGibs():
	# If it doesn't hit something with a hurt method it must be a wall
	var gibsInstance = gibs.instance()
	get_tree().get_root().add_child(gibsInstance)
	# Current position of the object spawning blood
	gibsInstance.global_transform.origin = global_transform.origin
	gibsInstance.EnableGibs()


func GetPickUpAble(pickupAble, amountToHeal):
	match pickupAble:
		PickUpAble.PICKUPTYPES.HEALTH:
			heal(amountToHeal)
			print(
				"[HealthManager.gd] - GetHealthPickUp() - The player has healed:",
				amountToHeal,
				"\nThe current player health is:",
				current_health
			)
