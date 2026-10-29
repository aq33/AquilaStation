/area/awaymission/vr/murderdome
	name = "Mordodrom"
	icon_state = "awaycontent8"
	pacifist = FALSE

/obj/structure/window/reinforced/fulltile/indestructable
	name = "wytrzymałe okno"
	flags_1 = PREVENT_CLICK_UNDER_1 | NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/grille/indestructable
	flags_1 = CONDUCT_1 | NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/spawner/structure/window/reinforced/indestructable
	spawn_list = list(/obj/structure/grille/indestructable, /obj/structure/window/reinforced/fulltile/indestructable)

/obj/structure/barricade/security/murderdome
	name = "odnawialna bariera"
	desc = "Bariera. Daje osłonę podczas strzelanin."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/murderdome/make_debris()
	new /obj/effect/murderdome/dead_barricade(get_turf(src))

/obj/effect/murderdome/dead_barricade
	name = "zniszczona bariera"
	desc = "Dawała osłonę podczas strzelanin. A teraz jej nie ma."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	alpha = 100

/obj/effect/murderdome/dead_barricade/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), 3 MINUTES)

/obj/effect/murderdome/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/murderdome(get_turf(src))
		qdel(src)
