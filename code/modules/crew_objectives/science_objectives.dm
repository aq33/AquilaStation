/*				SCIENCE OBJECTIVES				*/

/datum/objective/crew/cyborgs //Ported from old Hippie
	explanation_text = "Zapewnij przynajmniej (zgłoś to na GitHubie, coś się zepsuło) funkcjonujących cyborgów pod koniec zmiany."
	jobs = "researchdirector,roboticist"

/datum/objective/crew/cyborgs/New()
	. = ..()
	target_amount = rand(3,5)
	update_explanation_text()

/datum/objective/crew/cyborgs/update_explanation_text()
	. = ..()
	explanation_text = "Zapewnij przynajmniej [target_amount] funkcjonujących cyborgów pod koniec zmiany."

/datum/objective/crew/cyborgs/check_completion()
	var/borgcount = target_amount
	for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
		if(!(R.stat == DEAD))
			borgcount--
	if(borgcount <= 0)
		return TRUE
	else
		return ..()

//TODO: make the research objective work with techwebs
/*
/datum/objective/crew/research //inspired by old hippie's research level objective.
	var/datum/design/targetdesign
	explanation_text = "Dopilnuj, by do końca zmiany na serwerze B+R były dostępne badania potrzebne do wytworzenia: (coś się zepsuło, zgłoś to na GitHubie)."
	jobs = "researchdirector,scientist"

/datum/objective/crew/research/New()
	. = ..()
	targetdesign = pick(subtypesof(/datum/design))
	update_explanation_text()

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Dopilnuj, by do końca zmiany na serwerze B+R były dostępne badania potrzebne do wytworzenia: [initial(targetdesign.name)]."

/datum/objective/crew/research/check_completion()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(S?.files?.known_designs)
			if(targetdesign in S.files.known_designs)
				return TRUE
	return ..()
*/
