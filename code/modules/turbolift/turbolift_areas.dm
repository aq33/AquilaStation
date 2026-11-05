/area/shuttle/turbolift //Only use subtypes of this area
	requires_power = FALSE //no APCS in the lifts please
	ambient_buzz = 'nsv13/sound/effects/lift/elevatormusic.ogg' //Mandatory.
	ambientsounds = list('sound/effects/turbolift/elevatormusic.ogg')

/area/shuttle/turbolift/shaft //What the shuttle leaves behind
	name = "Szyb Turbowindy"
	requires_power = TRUE
	ambience_index = AMBIENCE_MAINT

/area/shuttle/turbolift/primary
	name = "Pierwsza Turbowinda"

/area/shuttle/turbolift/secondary
	name = "Druga Turbowinda"

/area/shuttle/turbolift/tertiary
	name = "Trzecia Turbowinda"

//NSV13 - added three more lift areas
/area/shuttle/turbolift/quaternary
	name = "Czwarta Turbowinda"

/area/shuttle/turbolift/quinary
	name = "Piąta Turbowinda"

/area/shuttle/turbolift/denary
	name = "Dziesiąta Turbowinda"
