/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "rolety"
	desc = "Wytrzymałe metalowe rolety otwierane mechanicznie."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/shutters/indestructible
	name = "wzmocnione rolety"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
