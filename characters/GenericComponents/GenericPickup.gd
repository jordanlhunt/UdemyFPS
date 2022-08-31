extends Area

class_name PickUpAble

enum PICKUPTYPES {
	MACHINEGUN,
	MACHINEGUNAMMO,
	SHOTGUN,
	SHOTGUNAMMO,
	ROCKETLAUNCHER,
	ROCKETLAUNCHERAMMO,
	HEALTH
}
export(PICKUPTYPES) var pickUpType
export var valueGainedFromPickUp = 0
