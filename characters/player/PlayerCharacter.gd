extends KinematicBody
var PlayerHotKeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}
# Onready means getting something from the current scene
onready var playerCamera = $Camera
onready var movementComponent = $MovementComponent
onready var health_manager = $HealthManager
onready var weaponManager = $Camera/WeaponManager
onready var pickUpManager = $PickupManager
export var mouse_sensitive = 0.5
var is_dead = false


func _ready():
	print("[PlayerCharacter.gd] - _ready() - Player creation complete")
	# Disable the mouse pointer
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Start the movement component
	movementComponent.initialize(self)
	pickUpManager.maxPlayerHealth = health_manager.max_health
	# Anytime the pickup manager updates the health the health_manager will know
	health_manager.connect("health_changed", pickUpManager, "UpdatePlayerHealth")
	pickUpManager.connect("hasPickedUpPickable", weaponManager, "GetPickUpAble")
	pickUpManager.connect("hasPickedUpPickable", health_manager, "GetPickUpAble")
	health_manager.initialize()
	health_manager.connect("dead", self, "kill")
	weaponManager.Initialize($Camera/FirePoint, [self])


# This is the Update() function
func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if is_dead:
		return
	# Create a 3D vector for 3D movement
	var movement_vector = Vector3()
	if Input.is_action_pressed("move_forwards"):
		movement_vector += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		movement_vector += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		movement_vector += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		movement_vector += Vector3.RIGHT
	movementComponent.set_movement_vector(movement_vector)
	if Input.is_action_just_pressed("jump"):
		movementComponent.jump()
	weaponManager.Attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))
	# Sprint Functionality
	if Input.is_action_just_pressed("sprint"):
		movementComponent.movement_acceleration = 6
	if Input.is_action_just_released("sprint"):
		movementComponent.movement_acceleration = 4


func _input(event):
	if event is InputEventMouseMotion:
		# Left and Right
		rotation_degrees.y -= mouse_sensitive * event.relative.x
		playerCamera.rotation_degrees.x -= mouse_sensitive * event.relative.y
		# Don't allow greater than 90 degrees of motion
		playerCamera.rotation_degrees.x = clamp(playerCamera.rotation_degrees.x, -90, 90)
	# Keyboard Input
	if event is InputEventKey and event.pressed:
		if event.scancode in PlayerHotKeys:
			weaponManager.switchToWeaponSlot(PlayerHotKeys[event.scancode])
	# Test Scrollwhell
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			weaponManager.switchToNextWeapon()
		if event.button_index == BUTTON_WHEEL_UP:
			weaponManager.switchToPreviousWeapon()


func TakeDamage(damage, direction):
	health_manager.TakeDamage(damage, direction)
	print("[PlayerCharacter.gd] - TakeDamage() - Player has taken damage")


func heal(amount):
	health_manager.heal(amount)


func kill():
	is_dead = true
	movementComponent.freezeBody()


func FlashMuzzleFlash():
	pass  # Replace with function body.
