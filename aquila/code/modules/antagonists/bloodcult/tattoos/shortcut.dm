
/datum/cult_tattoo/shortcut
	name = TATTOO_SHORTCUT
	desc = "Pozwala kreślić na ścianach sigile, przez które kultyści mogą przeskakiwać."
	icon_state = "shortcut"
	tier = 3
	blood_cost = 5

/turf/closed/wall/attack_hand(mob/user)
	. = ..()
	if(IS_CULTIST(user) && !(locate(/obj/effect/cult_shortcut) in src))
		var/datum/cult_tattoo/CT = user.checkTattoo(TATTOO_SHORTCUT)
		if(!CT)
			return
		if(user.occult_muted())
			return
		var/data = use_available_blood(user, CT.blood_cost)
		if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
			return
		if(!do_after(user, 3 SECONDS, target = src))
			return
		new /obj/effect/cult_shortcut(src)
		user.visible_message(span_warning("[user] maluje na [src] dziwny sigil."), \
						span_notice("Kończysz rysować sigil."))
		var/datum/antagonist/cult/cultist = user.mind?.has_antag_datum(/datum/antagonist/cult)
		cultist?.gain_devotion(5, DEVOTION_TIER_4, "shortcut_sigil", src)
