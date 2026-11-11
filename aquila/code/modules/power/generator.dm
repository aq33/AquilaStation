/obj/machinery/power/generator
	// Sprite TEG Quartofela (aq33/tgstation#569, przywrócony w aq33/tgstation#630)
	icon = 'aquila/icons/obj/power/teg.dmi'
	var/datum/looping_sound/generator/soundloop


/obj/machinery/power/generator/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/power/generator/Destroy()
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/atmospherics/components/binary/circulator
	icon = 'aquila/icons/obj/atmospherics/circulator.dmi'
