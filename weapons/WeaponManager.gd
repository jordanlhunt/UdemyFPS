extends Spatial
enum WEAPON_SLOTS { LONGKNIFE, MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER }
var weaponSlotsUnlocked = {
	WEAPON_SLOTS.LONGKNIFE: true,
	WEAPON_SLOTS.MACHINE_GUN: false,
	WEAPON_SLOTS.SHOTGUN: false,
	WEAPON_SLOTS.ROCKET_LAUNCHER: false,
}
onready var alertAreaHearing = $AlertAreaSound
onready var alertAreaLineOfSight = $AlertAreaLineOfSight
onready var animationPlayer = $AnimationPlayer
onready var playerWeapons = $Weapons.get_children()
signal currentAmmoUpdated
var bodiesToExclude: Array = []
var current_equipped_weapon = null
var current_weapon_slot = 0
var firePoint: Spatial


func _ready():
	pass


func Initialize(_firePoint: Spatial, _bodiesToExclude: Array):
	firePoint = _firePoint
	bodiesToExclude = _bodiesToExclude
	for weapon in playerWeapons:
		if weapon.has_method("Initialize"):
			weapon.Initialize(_firePoint, _bodiesToExclude)
	switchToWeaponSlot(WEAPON_SLOTS.LONGKNIFE)
	# Connect all the weapons to Alarm Foes
	playerWeapons[WEAPON_SLOTS.MACHINE_GUN].connect("fired", self, "AlertNearbyFoes")
	playerWeapons[WEAPON_SLOTS.SHOTGUN].connect("fired", self, "AlertNearbyFoes")
	playerWeapons[WEAPON_SLOTS.ROCKET_LAUNCHER].connect("fired", self, "AlertNearbyFoes")
	# Update the ammo count for each weapon
	for weapon in playerWeapons:
		weapon.connect("fired", self, "EmitCurrentAmmoUpdatedSignal")


func Attack(attackInputJustPressed: bool, attackInputHeld: bool):
	if current_equipped_weapon.has_method("Attack"):
		current_equipped_weapon.Attack(attackInputJustPressed, attackInputHeld)


# Switch to the next weapon
func switchToNextWeapon():
	current_weapon_slot = (current_weapon_slot + 1) % weaponSlotsUnlocked.size()
	print()
	if !weaponSlotsUnlocked[current_weapon_slot]:
		switchToNextWeapon()
	else:
		switchToWeaponSlot(current_weapon_slot)


func switchToPreviousWeapon():
	current_weapon_slot = posmod(current_weapon_slot - 1, weaponSlotsUnlocked.size())
	if !weaponSlotsUnlocked[current_weapon_slot]:
		switchToNextWeapon()
	else:
		switchToWeaponSlot(current_weapon_slot)


func switchToWeaponSlot(slotIndex):
	# Search only if input is with current size of weaponSlots
	if slotIndex < 0 or slotIndex >= weaponSlotsUnlocked.size():
		return
	# If that wepaon slot is not yet unlocked don't do anything
	if !weaponSlotsUnlocked[slotIndex]:
		return
	disableAllWeapons()
	current_equipped_weapon = playerWeapons[slotIndex]
	print("[WeaponManager.gd] - switchToWeaponSlot(slotIndex) - ", current_equipped_weapon.name)
	if current_equipped_weapon.has_method("SetActive"):
		current_equipped_weapon.SetActive()
	else:
		current_equipped_weapon.show()
	EmitCurrentAmmoUpdatedSignal()


func disableAllWeapons():
	for weapon in playerWeapons:
		if weapon.has_method("SetInactive"):
			weapon.SetInactive()
		else:
			weapon.hide()


func UpdateAnimation(velocity: Vector3, isOnGround: bool):
	if isOnGround and velocity.length() > 10:
		animationPlayer.play("BigMoving")
		# Shooting the weapon
	elif isOnGround and velocity.length() < 10 and velocity.length() > 1:
		animationPlayer.play("SmallMoving", 0.15)  # On the ground and/or not moving quickly.
	else:
		animationPlayer.play("Idle")


func AlertNearbyFoes():
	var nearByFoesInLineOfSight = alertAreaLineOfSight.get_overlapping_bodies()
	for foe in nearByFoesInLineOfSight:
		if foe.has_method("Alert"):
			foe.Alert()
	var nearByFoesInHearing = alertAreaHearing.get_overlapping_bodies()
	for foe in nearByFoesInHearing:
		if foe.has_method("Alert"):
			foe.Alert(false)


func GetPickUpAble(pickUpType, ammo):
	match pickUpType:
		# If player picks a machine gun for the first time they unlock that slot
		PickUpAble.PICKUPTYPES.MACHINEGUN:
			if !(weaponSlotsUnlocked[WEAPON_SLOTS.MACHINE_GUN]):
				weaponSlotsUnlocked[WEAPON_SLOTS.MACHINE_GUN] = true
				switchToWeaponSlot(WEAPON_SLOTS.MACHINE_GUN)
			playerWeapons[WEAPON_SLOTS.MACHINE_GUN].currentAmmo += ammo
		# If player picks up Machine Gun Ammo give it to them
		PickUpAble.PICKUPTYPES.MACHINEGUNAMMO:
			playerWeapons[WEAPON_SLOTS.MACHINE_GUN].currentAmmo += ammo
		# If player picks a shotgun for the first time they unlock that slot
		PickUpAble.PICKUPTYPES.SHOTGUN:
			if !(weaponSlotsUnlocked[WEAPON_SLOTS.SHOTGUN]):
				weaponSlotsUnlocked[WEAPON_SLOTS.SHOTGUN] = true
				switchToWeaponSlot(WEAPON_SLOTS.SHOTGUN)
			playerWeapons[WEAPON_SLOTS.SHOTGUN].currentAmmo += ammo
		# If player picks up Shotgun Ammo give it to them
		PickUpAble.PICKUPTYPES.SHOTGUNAMMO:
			playerWeapons[WEAPON_SLOTS.SHOTGUN].currentAmmo += ammo
		# If player picks a Rocket Launcher gun for the first time they unlock that slot
		PickUpAble.PICKUPTYPES.ROCKETLAUNCHER:
			if !(weaponSlotsUnlocked[WEAPON_SLOTS.ROCKET_LAUNCHER]):
				weaponSlotsUnlocked[WEAPON_SLOTS.ROCKET_LAUNCHER] = true
				switchToWeaponSlot(WEAPON_SLOTS.ROCKET_LAUNCHER)
			playerWeapons[WEAPON_SLOTS.ROCKET_LAUNCHER].currentAmmo += ammo
		# If player picks up Rocket Launcher Ammo give it to them
		PickUpAble.PICKUPTYPES.ROCKETLAUNCHERAMMO:
			playerWeapons[WEAPON_SLOTS.ROCKET_LAUNCHER].currentAmmo += ammo
	EmitCurrentAmmoUpdatedSignal()


func EmitCurrentAmmoUpdatedSignal():
	emit_signal("currentAmmoUpdated", current_equipped_weapon.currentAmmo)
	print(
		"[WeaponManager.gd] - EmitCurrentAmmoUpdatedSignal() - Ammo:",
		current_equipped_weapon.currentAmmo,
		" Current Weapon:",
		current_equipped_weapon.name
	)
