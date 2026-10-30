/obj/item/implant/stealth
	name = "implant S3"
	desc = "Pozwala ci ukryć się na widoku."
	actions_types = list(/datum/action/item_action/agent_box)

/obj/item/implanter/stealth
	name = "implanter (kamuflaż)"
	imp_type = /obj/item/implant/stealth

//Box Object

/obj/structure/closet/cardboard/agent
	name = "niepozorne pudło"
	desc = "Jest tak zwyczajne, że wcześniej go nie zauważyłeś."
	icon_state = "agentbox"
	max_integrity = 1 // "This dumb box shouldn't take more than one hit to make it vanish."
	move_speed_multiplier = 0.5

/obj/structure/closet/cardboard/agent/proc/go_invisible()
	animate(src, , alpha = 0, time = 20)

/obj/structure/closet/cardboard/agent/Initialize(mapload)
	. = ..()
	go_invisible()


/obj/structure/closet/cardboard/agent/open()
	. = ..()
	qdel(src)

/obj/structure/closet/cardboard/agent/process()
	alpha = max(0, alpha - 50)

/obj/structure/closet/cardboard/agent/proc/reveal()
	alpha = 255
	addtimer(CALLBACK(src, PROC_REF(go_invisible)), 10, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/structure/closet/cardboard/agent/Bump(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()

/obj/structure/closet/cardboard/agent/Bumped(atom/movable/A)
	. = ..()
	if(isliving(A))
		reveal()
