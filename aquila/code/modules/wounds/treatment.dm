// AQUILA - treating wounds with medical stacks (the wound surgeries are in aquila/code/modules/surgery_tg/)

/// Medical stacks treat a wound on the targeted limb before doing their usual healing
/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()

/// Returns TRUE if the stack went to a wound (even if the treatment was interrupted)
/obj/item/stack/medical/proc/try_treat_wound(mob/living/carbon/patient, mob/user)
	if(patient in user.do_afters)
		return FALSE
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	var/datum/wound/wound = patient.get_treatable_wound(limb, src)
	if(!wound)
		return FALSE
	INVOKE_ASYNC(wound, TYPE_PROC_REF(/datum/wound, treat), src, user)
	return TRUE

/obj/item/stack/medical/suture/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()

/obj/item/stack/medical/mesh/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()
