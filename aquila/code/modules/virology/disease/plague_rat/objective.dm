/datum/objective/plague
	name = "Spread your disease."
	explanation_text = "Spread your disease among the station's inhabitants."
	var/disease_id = ""
	var/total_infections = 0

/datum/objective/plague/update_explanation_text()
	var/current_infections = 0
	for (var/mob/living/L in GLOB.mob_living_list)
		if (length(L.diseases))
			for(var/datum/disease/disease in L.diseases)
				if("[disease.uniqueID]-[disease.subID]" != disease_id)
					continue
			current_infections++
	explanation_text = "Spread your disease among the station's inhabitants. ([total_infections] infections caused in total. [current_infections] infected individuals remaining.)"

/datum/objective/plague/check_completion()
	if (..())
		return TRUE

	if (total_infections > 1)
		// AQ: L.diseases trzyma datumy, a disease_id to tekst "uniqueID-subID" - trzeba porownac po polach
		for (var/mob/living/L in GLOB.mob_living_list)
			if (L.stat == DEAD) // z mob_living_list wypada dopiero w Destroy(), wiec trupy trzeba odfiltrowac
				continue
			for (var/datum/disease/acute/carried in L.diseases)
				if (istype(carried) && "[carried.uniqueID]-[carried.subID]" == disease_id)
					return TRUE//if we infected at least one individual, and there is still an infected individual alive, that's good enough.

	return FALSE
