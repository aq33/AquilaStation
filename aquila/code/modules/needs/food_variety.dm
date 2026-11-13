// AQUILA - urozmaicona dieta. Kilka różnych grup jedzenia w ostatnich ~20 minutach daje moodlet i trochę sytości.
// Monotonna dieta nie ma kary, tylko brak premii. Kęs liczony w TakeBite(), tam też kwas żołądkowy od śmieciowego jedzenia.

/// Okno, w którym liczą się zjedzone grupy
#define AQ_VARIETY_WINDOW (20 MINUTES)
/// Ile różnych grup daje premię
#define AQ_VARIETY_GROUPS 4

/// Grupy jedzenia liczone do urozmaicenia (bity foodtypes)
GLOBAL_LIST_INIT(aq_variety_groups, list(MEAT, VEGETABLES, FRUIT, GRAIN, DAIRY))

/mob/living/carbon/human
	/// Grupa jedzenia ("[bit]") -> kiedy ostatnio zjedzona
	var/list/aq_food_groups_eaten
	/// Do kiedy premia za urozmaicenie nie daje znowu sytości
	var/aq_next_variety_satiety = 0

/datum/mood_event/aq_varied_diet
	description = "<span class='nicegreen'>Jem urozmaicone posiłki.</span>\n"
	mood_change = 4
	timeout = 15 MINUTES

/datum/component/edible/TakeBite(mob/living/eater, mob/living/feeder)
	var/bite_types = foodtypes
	var/junk = (foodtypes & (JUNKFOOD|FRIED)) || HAS_TRAIT(parent, TRAIT_FOOD_FRIED) || HAS_TRAIT(parent, TRAIT_AQ_VENDED)
	var/atom/owner = parent
	var/bite_amount = min(bite_consumption, owner.reagents?.total_volume)
	. = ..()
	if(. && ishuman(eater))
		var/mob/living/carbon/human/human_eater = eater
		human_eater.aq_note_food_variety(bite_types)
		human_eater.aq_stomach_bite(junk, bite_types, bite_amount)

/// Zapisuje zjedzone grupy i daje premię, gdy w ostatnich 20 minutach było ich dość
/mob/living/carbon/human/proc/aq_note_food_variety(types)
	for(var/group in GLOB.aq_variety_groups)
		if(types & group)
			LAZYSET(aq_food_groups_eaten, "[group]", world.time)
	var/count = 0
	for(var/group in aq_food_groups_eaten)
		if(world.time - aq_food_groups_eaten[group] <= AQ_VARIETY_WINDOW)
			count++
	if(count < AQ_VARIETY_GROUPS)
		return FALSE
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "aq_variety", /datum/mood_event/aq_varied_diet)
	if(world.time >= aq_next_variety_satiety)
		aq_next_variety_satiety = world.time + 5 MINUTES
		satiety = min(satiety + 50, MAX_SATIETY)
		to_chat(src, "<span class='nicegreen'>Urozmaicona dieta dobrze ci robi.</span>")
	return TRUE

#undef AQ_VARIETY_WINDOW
#undef AQ_VARIETY_GROUPS
