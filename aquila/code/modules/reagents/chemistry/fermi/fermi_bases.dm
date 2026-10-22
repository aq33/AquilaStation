// Ustawienia fermichemu z typów bazowych tg (tgstation@b3949ec362), które dziedziczą też nasze przepisy bez odpowiednika w tg.
// Konkretne przepisy z odpowiednikiem w tg nadpisuje wygenerowany fermi_data.dm.

// tg: slime_extracts.dm - every slime extract reaction is instant
/datum/chemical_reaction/slime
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_SLIME

// tg: pyrotechnics.dm - explosions happen at once and at any temperature
/datum/chemical_reaction/reagent_explosion
	reaction_flags = REACTION_INSTANT
	reaction_tags = REACTION_TAG_EXPLOSIVE | REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_ACTIVE
	required_temp = 0 //Prevent impromptu RPGs

// tg: food_mixtures.dm
/datum/chemical_reaction/food
	optimal_temp = 400
	temp_exponent_factor = 1
	optimal_ph_min = 2
	optimal_ph_max = 10
	H_ion_release = 0
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY
