/obj/item/sbeacondrop/exploration
	name = "nadajnik bluespace"
	desc = "Etykieta głosi: <i>Uwaga: aktywacja tego urządzenia ściągnie w twoje położenie giganadajnik bluespace, dzięki któremu wrócisz do obiecujących stacji.</i>"
	droptype = /obj/structure/bluespace_beacon

//Beacon structure

/obj/structure/bluespace_beacon
	name = "giganadajnik bluespace"
	desc = "Zapisuje lokalizację na mapie nawigacyjnej, by można było do niej wrócić w dowolnej chwili."
	icon = 'icons/obj/machines/NavBeacon.dmi'
	icon_state = "beacon-item"
	density = TRUE

	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

	light_power = 2
	light_range = 3
	light_color = "#cd87df"

	anchored = TRUE

/obj/structure/bluespace_beacon/Initialize(mapload)
	. = ..()
	GLOB.zclear_blockers += src

/obj/structure/bluespace_beacon/Destroy()
	GLOB.zclear_blockers -= src
	. = ..()

/obj/structure/bluespace_beacon/wrench_act(mob/living/user, obj/item/I)
	if(anchored)
		to_chat(user, "<span class='notice'>Zaczynasz odkręcać [src]...</span>")
	else
		to_chat(user, "<span class='notice'>Zaczynasz przykręcać [src]...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		if(QDELETED(I))
			return
		if(anchored)
			to_chat(user, "<span class='notice'>Odkręcasz [src].</span>")
		else
			to_chat(user, "<span class='notice'>Przykręcasz [src].</span>")
		anchored = !anchored
