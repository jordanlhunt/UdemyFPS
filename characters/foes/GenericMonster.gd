extends KinematicBody
#States
enum StatesEnum { IDLE, CHASE, ATTACK, DEAD }

export var angleConeOfVision = 40.0
export var attackAngle = 5.0
export var attackRange = 2.0
export var attackRateInSeconds = .6
export var attackRateInSecondsModifier = .5
export var turnSpeed = 360.0
onready var animationPlayer = $Graphics/AnimationPlayer
onready var heatlhManager = $HealthManager
onready var movmentComponent = $MovementComponent
onready var navgiationNode: Navigation = get_parent()
var attackCooldownTimer: Timer
var currentState = StatesEnum.IDLE
var isAbleToAttack = true
var movementPath = []
var playerCharacter = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup monster timer
	attackCooldownTimer = Timer.new()
	attackCooldownTimer.wait_time = attackRateInSeconds
	attackCooldownTimer.connect("timeout", self, "FinishAttack")
	attackCooldownTimer.one_shot = true
	add_child(attackCooldownTimer)
	
	# Get a reference to the player character
	playerCharacter = get_tree().get_nodes_in_group("playerCharacter")[0]
	var monsterSkeleton = $Graphics/Armature/Skeleton.get_children()
	for bone in monsterSkeleton:
		for child in bone.get_children():
			if child is Hitbox:
				child.connect("TakeDamage", self, "TakeDamage")
	heatlhManager.connect("dead", self, "SetStateDead")
	heatlhManager.connect("gibbed", $Graphics, "hide")
	movmentComponent.initialize(self)
	SetStateIdle()


func TakeDamage(damage: int, directionDamageCameFrom: Vector3):
	# If hit in the idle state chase the player
	if currentState == StatesEnum.IDLE:
		SetStateChase()
	print(
		"[GenericMonster.gd] - TakeDamage() - This monster has been taken damage. Damage taken = ",
		damage
	)
	heatlhManager.TakeDamage(damage, directionDamageCameFrom)


func _process(delta):
	match currentState:
		StatesEnum.IDLE:
			ProcessStateIdle(delta)
		StatesEnum.CHASE:
			ProcessStateChase(delta)
		StatesEnum.ATTACK:
			ProcessStateAttack(delta)
		StatesEnum.DEAD:
			ProcessStateDead(delta)


func SetStateIdle():
	currentState = StatesEnum.IDLE
	animationPlayer.play("idle_loop")


func ProcessStateIdle(delta):
	if CanSeePlayer():
		SetStateChase()


func SetStateChase():
	currentState = StatesEnum.CHASE
	# Animate the chase
	animationPlayer.play("walk_loop", 0.1)


func ProcessStateChase(delta):
	if WithinAttackDistanceOfPlayer() and HasLineOfSightOfPlayer():
		SetStateAttack()
	var playerPosition = playerCharacter.global_transform.origin
	var currentPosition = global_transform.origin
	movementPath = navgiationNode.get_simple_path(currentPosition, playerPosition)
	var goalPosition = playerPosition
	if movementPath.size() > 1:
		goalPosition = movementPath[1]
	var directionToFace = goalPosition - currentPosition
	directionToFace.y = 0
	movmentComponent.set_movement_vector(directionToFace)
	FaceDirection(directionToFace, delta)


func SetStateAttack():
	currentState = StatesEnum.ATTACK


func ProcessStateAttack(delta):
	movmentComponent.set_movement_vector(Vector3.ZERO)
	if !IsPlayerWithinSightAngle(attackAngle):
		#Face the player in the attack
		FaceDirection(
			global_transform.origin.direction_to(playerCharacter.global_transform.origin), delta
		)
	if isAbleToAttack:
		if !WithinAttackDistanceOfPlayer() or !CanSeePlayer():
			SetStateChase()
		elif !IsPlayerWithinSightAngle(attackAngle):
			#Face the player in the attack
			FaceDirection(
				global_transform.origin.direction_to(playerCharacter.global_transform.origin), delta
			)
		else:
			StartAttack()


func SetStateDead():
	currentState = StatesEnum.DEAD
	animationPlayer.play("die")
	# Don't allow the movement after death
	movmentComponent.freezeBody()
	# Allow the player to walk over dead bodies
	$CollisionShape.disabled = true


func ProcessStateDead(delta):
	pass


func IsPlayerWithinSightAngle(sightAngle: float):
	var directonToPlayer = global_transform.origin.direction_to(
		playerCharacter.global_transform.origin
	)
	var forwardsVector = global_transform.basis.z
	# Check if the player the cone of vision of the bird.
	return rad2deg(forwardsVector.angle_to(directonToPlayer)) < sightAngle


func CanSeePlayer():
	return IsPlayerWithinSightAngle(angleConeOfVision) and HasLineOfSightOfPlayer()


func HasLineOfSightOfPlayer():
	var selfPosition = global_transform.origin + Vector3.UP
	var playerPosition = playerCharacter.global_transform.origin + Vector3.UP
	var currentSpaceState = get_world().get_direct_space_state()
	var result = currentSpaceState.intersect_ray(selfPosition, playerPosition, [], 1)
	# If the result value is not zero then it has line of the player
	if result:
		return false
	return true


func Alert(checkLineOfSight = true):
	# If it's currently doing something let it continue to do whatever
	if currentState != StatesEnum.IDLE:
		return
	# Doesn't have line of sight
	if checkLineOfSight and !HasLineOfSightOfPlayer():
		return
	SetStateChase()


func FaceDirection(direction: Vector3, delta):
	var angleDifference = global_transform.basis.z.angle_to(direction)
	# Negative number is to the left, positeve is to the right, which way is fastest to reach goal angle
	var turnDirection = sign(global_transform.basis.x.dot(direction))
	if abs(angleDifference) < (deg2rad(turnSpeed) * delta):
		rotation.y = atan2(direction.x, direction.z)
	else:
		rotation.y += deg2rad(turnSpeed) * delta * turnDirection


func StartAttack():
	isAbleToAttack = false
	animationPlayer.play("attack", -1, attackRateInSecondsModifier)
	attackCooldownTimer.start()


func FinishAttack():
	isAbleToAttack = true
	pass


func WithinAttackDistanceOfPlayer():
	return (
		global_transform.origin.distance_to(playerCharacter.global_transform.origin)
		< attackRange
	)


func EmitAttackSignal():
	emit_signal("Attack")


func Fire():
	pass  # Replace with function body.
