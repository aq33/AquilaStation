/// AQUILA - pojmanie szefa zamiast zabójstwa (rozwój antagonistów, rewolucja).
/// Na koniec rundy cel buntu uznaje szefa za pokonanego także wtedy, gdy siedzi skuty w brygu albo w areszcie rewolucji
/// (to samo pomieszczenie co przytomny, nieskuty rewolucjonista). W trakcie rundy liczy się dalej tylko śmierć i wygnanie,
/// więc skucie szefa nie kończy rewolucji od razu. Pomysł z tg („Assassinate, capture or convert”) i SS220 („Brig X”).

/// Obszary, które liczą się jako bryg
GLOBAL_LIST_INIT(aquila_brig_areas, typecacheof(list(
	/area/security/brig,
	/area/security/prison,
	/area/security/processing,
)))

/datum/objective/mutiny/check_completion()
	. = ..()
	if(. || SSticker.current_state < GAME_STATE_FINISHED)
		return
	return target_captured()

/datum/objective/mutiny/update_explanation_text()
	..()
	if(target?.current)
		explanation_text += " Na koniec zmiany liczy się też skucie w brygu albo w areszcie rewolucji."

/// Szef jest skuty w brygu albo w areszcie rewolucji
/datum/objective/mutiny/proc/target_captured()
	var/mob/living/carbon/prisoner = target?.current
	if(!istype(prisoner) || !prisoner.handcuffed || prisoner.stat == DEAD)
		return FALSE
	var/area/cell = get_area(prisoner)
	if(!cell)
		return FALSE
	if(is_type_in_typecache(cell, GLOB.aquila_brig_areas))
		return TRUE
	return rev_custody(prisoner, team?.members)

/// Areszt rewolucji: w tym samym pomieszczeniu co więzień pilnuje go przytomny, nieskuty członek drużyny rewolucji
/// (nawrócony z powrotem wypada z drużyny)
/datum/objective/mutiny/proc/rev_custody(mob/living/carbon/prisoner, list/datum/mind/guards)
	var/area/cell = get_area(prisoner)
	for(var/datum/mind/guard_mind as anything in guards)
		var/mob/living/guard = guard_mind?.current
		if(!istype(guard) || guard == prisoner || guard.stat != CONSCIOUS || guard.restrained())
			continue
		if(get_area(guard) == cell)
			return TRUE
	return FALSE
