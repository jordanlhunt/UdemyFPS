extends Area

signal hasPickedUpPickable

var maxPlayerHealth = 0
var currentPlayerHealth = 0


func UpdatePlayerHealth(amount):
	currentPlayerHealth = amount


func _ready():
	connect("area_entered", self, "OnAreaEntered")


# Passes information of the object that has entered an area
func OnAreaEntered(pickupAble: PickUpAble):
	# If player picks up a healthpack at max health just do nothing
	if (
		pickupAble.pickUpType == PickUpAble.PICKUPTYPES.HEALTH
		and currentPlayerHealth == maxPlayerHealth
	):
		return
	else:
		emit_signal("hasPickedUpPickable", pickupAble.pickUpType, pickupAble.valueGainedFromPickUp)
	# Free the pickup
	pickupAble.queue_free()
