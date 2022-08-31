extends Label

const MAXNUMBEROFVISABLELINES = 5
var pickUpInfoArray = []


func _ready():
	text = ""


func AddPickUpInfo(pickUpType, value):
	$ClearTimer.start()
	match pickUpType:
		PickUpAble.PICKUPTYPES.MACHINEGUN:
			pickUpInfoArray.push_back("Picked a Reynolds AR19")
		PickUpAble.PICKUPTYPES.MACHINEGUNAMMO:
			pickUpInfoArray.push_back("Picked up rilfe ammo" + str(value))
		PickUpAble.PICKUPTYPES.SHOTGUN:
			pickUpInfoArray.push_back("Picked up a RedCrown Model No. 9 ")
		PickUpAble.PICKUPTYPES.SHOTGUNAMMO:
			pickUpInfoArray.push_back("Picked up shotgun ammo  " + str(value))
		PickUpAble.PICKUPTYPES.ROCKETLAUNCHER:
			pickUpInfoArray.push_back("Horror ardiente")
		PickUpAble.PICKUPTYPES.ROCKETLAUNCHERAMMO:
			pickUpInfoArray.push_back("Picked up a rocket Ammo  " + str(value))
	while pickUpInfoArray.size() >= MAXNUMBEROFVISABLELINES:
		pickUpInfoArray.pop_front()
	UpdateDisplay()


func RemovePickUpsInfo():
	if pickUpInfoArray.size() > 0:
		pickUpInfoArray.pop_front()
	UpdateDisplay()


func UpdateDisplay():
	text = ""
	for infoText in pickUpInfoArray:
		text += infoText + "\n"
