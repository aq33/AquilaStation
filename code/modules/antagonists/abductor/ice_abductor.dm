/obj/structure/fluff/iced_abductor ///Unless more non-machine ayy structures made, it will stay in fluff.
	name = "tajemniczy blok lodu"
	desc = "W tym solidnym bloku lodu spoczywa mroczna postać. Kto wie, skąd się wzięła?"
	icon = 'icons/effects/freeze.dmi'
	icon_state =  "ice_ayy"
	density = TRUE
	deconstructible = FALSE

/obj/structure/fluff/iced_abductor/Destroy()
	var/turf/T = get_turf(src)
	new /obj/effect/mob_spawn/human/abductor(T)
	. = ..()
