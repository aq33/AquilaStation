/datum/mutation/radioactive
	name = "Radioaktywność"
	desc = "Niestabilna mutacja, przez którą nosiciel emituje śmiercionośne promieniowanie beta. Działa ono zarówno na nosiciela, jak i na otoczenie."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Czujesz to w kościach!</span>"
	instability = 5
	difficulty = 8
	power_coeff = 1


	COOLDOWN_DECLARE(last_radioactive_pulse) // AQ EDIT - promieniowanie z Bee#13442

/datum/mutation/radioactive/on_life()
	// AQ EDIT START - promieniowanie z Bee#13442
	if(!COOLDOWN_FINISHED(src, last_radioactive_pulse))
		return
	COOLDOWN_START(src, last_radioactive_pulse, 5 SECONDS)
	radiation_pulse(owner, max_range = 1 * (GET_MUTATION_POWER(src) * 2), threshold = RAD_MEDIUM_INSULATION)
	// AQ EDIT END

/datum/mutation/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/radioactive/get_visual_indicator()
	return visual_indicators[type][1]
