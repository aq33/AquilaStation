
/datum/reagent/consumable/ethanol/amarena
	name = "Amarena"
	description = "Dobre wino, niska cena, dobre wino, amarena."
	boozepwr = 20
	color = "#800101"
	quality = DRINK_NICE
	taste_description = "wiśnia"
	glass_icon_state = "amarenaglass"
	glass_name = "kieliszek amareny"
	glass_desc = "Dobre wino, niska cena, dobre wino, amarena."

/// Stronger booze hydrates less. Like every drink, scaled by REAGENTS_METABOLISM (hydration per tick)
/datum/reagent/consumable/ethanol/get_hydration_factor()
	return LERP(15, 0, boozepwr/100) * REAGENTS_METABOLISM
