extends Spatial
# This script will be applied to players as well as AI
# Export variables can be edited in the GUI
export var gravity_force = 60
export var ignore_rotation = false
export var jump_force = 13.5
export var max_speed = 7
export var movement_acceleration = 4
var body_to_move : KinematicBody = null
var drag = 0.0
var movement_vector = Vector3()
var pressed_jump = false
var snap_vector = Vector3()
var velocity = Vector3() 
var is_frozen = false
signal movement_information 
# Ready is like initialize 
func _ready():
	drag = float(movement_acceleration) / max_speed
func initialize(new_body_to_move : KinematicBody):
	body_to_move = new_body_to_move
func jump():
	pressed_jump = true
func set_movement_vector(_movement_vector: Vector3):
	movement_vector = _movement_vector.normalized()
func _physics_process(delta):
	if is_frozen:
		return
	var current_movement_vector = movement_vector
	if !ignore_rotation:
		current_movement_vector = current_movement_vector.rotated(Vector3.UP, body_to_move.rotation.y)
	# Move in direction you're facing
	velocity += movement_acceleration * current_movement_vector - velocity * Vector3(drag, 0,drag) + gravity_force * Vector3.DOWN * delta
	velocity = body_to_move.move_and_slide_with_snap(velocity,snap_vector,Vector3.UP)
	var is_grounded = body_to_move.is_on_floor()
	if is_grounded:
		velocity.y = -0.01
	if is_grounded and pressed_jump: 
		velocity.y = jump_force
		snap_vector = Vector3.ZERO
	else:
		snap_vector = Vector3.DOWN
	pressed_jump = false
	emit_signal("movement_information", velocity, is_grounded)
func freezeBody():
	is_frozen = true
func unfreezeBody():
	is_frozen = false
