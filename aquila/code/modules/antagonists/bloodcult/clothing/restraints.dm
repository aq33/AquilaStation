/obj/item/restraints/handcuffs/cult
	name = "upiorne więzy"
	desc = ""
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "cultcuff"
	breakouttime = 60 SECONDS
	var/datum/antagonist/cult/gaoler

/obj/item/restraints/handcuffs/cult/New()
	..()

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		return

	cult.bindings += src

/obj/item/restraints/handcuffs/cult/Destroy()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult?.bindings -= src
	return ..()

/obj/item/restraints/handcuffs/cult/examine(mob/user)
	. = ..()
	if (!isliving(loc))//shouldn't happen unless they get admin spawned
		. += span_info("Macki wijące się z tego jajowatego przedmiotu zdają się próbować chwycić wszystko dookoła.")
	else
		var/mob/living/carbon/C = loc
		if (C.handcuffed == src)
			. += span_info("Krępują ci ręce i zadają ogromny ból ciału i duszy. Ale z czasem powinno ci się udać je zerwać.")
		else
			. += span_info("[C] wyraźnie cierpi, gdy krępują mu ręce.")

/obj/item/restraints/handcuffs/cult/narsie_act()
	return

/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "cieniste kajdany"
	desc = "Kajdany, które spinają nadgarstki złowrogą magią."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message(span_danger("Kajdany [user] pękają w wyładowaniu mrocznej magii!"), \
							span_userdanger("[src] pękają w wyładowaniu mrocznej magii!"))
	. = ..()

/obj/item/restraints/legcuffs/bola/cult
	name = "\improper bola Nar'Sie"
	desc = "Mocna bola spleciona mroczną magią, dzięki której nieszkodliwie przelatuje przez kultystów Nar'Sie. Rzuć nią, by przewrócić i spowolnić ofiarę."
	icon_state = "bola_cult"
	item_state = "bola_cult"
	breakouttime = 6 SECONDS
	knockdown = 30

#define CULT_BOLA_PICKUP_STUN (6 SECONDS)
/obj/item/restraints/legcuffs/bola/cult/attack_hand(mob/living/carbon/user, list/modifiers)
	. = ..()

	if(IS_CULTIST(user) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	if(user.get_num_legs(FALSE) < 2 || carbon_user.legcuffed) //if they can't be ensnared, stun for the same time as it takes to breakout of bola
		to_chat(user, span_cultlarge("\"Nie radziłabym tego.\""))
		user.dropItemToGround(src, TRUE)
		user.Paralyze(CULT_BOLA_PICKUP_STUN)
	else
		to_chat(user, span_warning("Bola zdaje się ożywać!"))
		ensnare(user)
#undef CULT_BOLA_PICKUP_STUN


/obj/item/restraints/legcuffs/bola/cult/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/hit_mob = hit_atom
	if (istype(hit_mob) && IS_CULTIST(hit_mob))
		return
	. = ..()
