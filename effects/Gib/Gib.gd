extends KinematicBody
export var startMovementSpeed = 30
export var gravity = 35.0
export var drag = 0.01
export var velocityRetainedOnBounce = 0.8
var velocity = Vector3.ZERO
var isInitialized = false


func _ready():
	Initialize()


func Initialize():
	isInitialized = true
	velocity = -global_transform.basis.y * startMovementSpeed


func _physics_process(delta):
	if !isInitialized:
		return
	velocity += -velocity * drag + Vector3.DOWN * gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		var directionTravelling = velocity
		var collisionNormal = collision.normal
		var reflectedRay = (
			directionTravelling
			- 2 * directionTravelling.dot(collisionNormal) * collisionNormal
		)
		velocity = reflectedRay * velocityRetainedOnBounce
