// AQUILA - Dym i zapachy: oddychanie i węszenie
// In Monke breathe_act() was never called, so only *sniff did anything. Here every breath from the room air counts.

/mob/living/carbon
	/// world.time after which we notice smells on our own again
	var/next_smell = 0

/// Called once per breath from /obj/item/organ/lungs/check_breath(), next to handle_miasma_breath()
/obj/item/organ/lungs/proc/handle_pollution_breath(mob/living/carbon/human/H)
	var/turf/open/breathed_turf = H.loc
	if(!istype(breathed_turf) || QDELETED(breathed_turf.pollution))
		return
	// Internals and gas masks keep the room air out
	if(H.internal || H.has_smoke_protection())
		return
	breathed_turf.pollution.breathe_act(H)
	if(world.time < H.next_smell || QDELETED(breathed_turf.pollution))
		return
	if(breathed_turf.pollution.smell_act(H))
		H.next_smell = world.time + SMELL_COOLDOWN

/datum/emote/living/sniff/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/turf/open/current_turf = get_turf(user)
	if(!istype(current_turf) || QDELETED(current_turf.pollution))
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.internal) //Breathing from internals means we cant smell
			return
		carbon_user.next_smell = world.time + SMELL_COOLDOWN
	current_turf.pollution.smell_act(user)
