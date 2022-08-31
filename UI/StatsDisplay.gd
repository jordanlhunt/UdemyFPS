extends Label
var ammo = 0
var health = 0


func UpdateAmmo(newAmmoAmount):
	ammo = newAmmoAmount
	UpdateDisplay()


func UpdateHealth(newHealthAmmount):
	health = newHealthAmmount
	UpdateDisplay()


func UpdateDisplay():
	text = "Health: " + str(health)
	var currentAmmoCount = str(ammo)
	if ammo < 0:
		currentAmmoCount = "∞"
	text += "\nAmmo: " + currentAmmoCount
