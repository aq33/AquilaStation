// AQUILA - port z tgstation (code/game/machinery/dna_infuser/dna_infusion.dm)

/// czy osoba w maszynie może przejść infuzję
/atom/movable/proc/can_infuse(mob/feedback_target)
	if(feedback_target)
		balloon_alert(feedback_target, "brak DNA!")
	return FALSE

/mob/living/can_infuse(mob/feedback_target)
	if(feedback_target)
		balloon_alert(feedback_target, "zbyt proste DNA!")
	return FALSE

/mob/living/carbon/human/can_infuse(mob/feedback_target)
	if(HAS_TRAIT(src, TRAIT_BADDNA))
		if(feedback_target)
			balloon_alert(feedback_target, "DNA uszkodzone!")
		return FALSE
	if(!can_mutate())
		if(feedback_target)
			balloon_alert(feedback_target, "brak DNA!")
		return FALSE
	return TRUE

/// wpis infusera pasujący do próbki; mucha, jeśli nic nie pasuje
/atom/movable/proc/get_infusion_entry()
	for(var/entry_type in GLOB.infuser_entries)
		var/datum/infuser_entry/entry = GLOB.infuser_entries[entry_type]
		if(entry.tier == DNA_MUTANT_UNOBTAINABLE)
			continue
		if(entry.matches_input(src))
			return entry
	return GLOB.infuser_entries[/datum/infuser_entry/fly]

/// Podmienia jeden organ na zmutowany odpowiednik. TRUE przy sukcesie.
/mob/living/carbon/human/proc/infuse_organ(datum/infuser_entry/entry, atom/movable/infused_from)
	var/obj/item/organ/new_organ = pick_infusion_organ(entry, infused_from)
	if(!new_organ)
		return FALSE
	new_organ = new new_organ()
	new_organ.replace_into(src)
	new_organ.organ_flags |= ORGAN_MUTANT
	return TRUE

/// Losuje typ organu z wpisu, który pasuje do tej osoby:
/// 1. musi mieć organ w tym samym slocie, albo nowy organ jest zewnętrzny (ogon, skrzydła, rogi...);
/// 2. stary organ nie może być robotyczny;
/// 3. nie może już mieć identycznego organu.
/mob/living/carbon/human/proc/pick_infusion_organ(datum/infuser_entry/entry, atom/movable/infused_from)
	if(!entry)
		return FALSE
	var/list/potential_new_organs = entry.get_output_organs(src, infused_from)
	for(var/obj/item/organ/new_organ as anything in potential_new_organs.Copy())
		var/obj/item/organ/old_organ = getorganslot(initial(new_organ.slot))
		if(old_organ)
			if(old_organ.type != new_organ && old_organ.status != ORGAN_ROBOTIC && !(old_organ.organ_flags & ORGAN_SYNTHETIC))
				continue // stary organ da się zmutować
		else if(initial(new_organ.infuser_external))
			continue // zewnętrzny organ może wyrosnąć
		potential_new_organs -= new_organ
	if(length(potential_new_organs))
		return pick(potential_new_organs)
	return FALSE
