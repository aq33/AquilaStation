/datum/mutation/radioactive
	name = "Radioaktywność"
	desc = "Niestabilna mutacja, przez którą nosiciel emituje śmiercionośne promieniowanie beta. Działa ono zarówno na nosiciela, jak i na otoczenie."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Czujesz to w kościach!</span>"
	instability = 5
	difficulty = 8
	power_coeff = 1


/datum/mutation/radioactive/on_life()
	radiation_pulse(owner, 20 * GET_MUTATION_POWER(src))

/datum/mutation/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/radioactive/get_visual_indicator()
	return visual_indicators[type][1]
