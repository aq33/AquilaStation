/datum/reagent/adrenaline
	name = "Liquid Adrenaline"
	description = "Dangerous in large quantities"
	color = "#ffffff"
	overdose_threshold = 11
	metabolization_rate = 1

/datum/reagent/adrenaline/on_mob_metabolize(mob/living/L)
	. = ..()
	// AQ: nie mamy /datum/movespeed_modifier/reagent/stimulants, wiec adrenalina nie przyspiesza
	ADD_TRAIT(L, TRAIT_BATON_RESISTANCE, type)

/datum/reagent/adrenaline/on_mob_end_metabolize(mob/living/L)

	REMOVE_TRAIT(L, TRAIT_BATON_RESISTANCE, type)
	..()

/datum/reagent/adrenaline/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	M.AdjustStun(-0.5 SECONDS)
	M.AdjustKnockdown(-0.5 SECONDS)
	M.AdjustUnconscious(-0.5 SECONDS)
	M.AdjustImmobilized(-0.5 SECONDS)
	M.AdjustParalyzed(-0.5 SECONDS)
	M.adjustStaminaLoss(-10, FALSE)

/datum/reagent/adrenaline/overdose_start(mob/living/M)
	. = ..()
	to_chat(M, span_danger("You can feel your everything start to hurt."))

/datum/reagent/adrenaline/overdose_process(mob/living/M, seconds_per_tick, times_fired)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.2 * seconds_per_tick)
	if(SPT_PROB(18, seconds_per_tick))
		M.adjustStaminaLoss(1.25, FALSE)
		M.adjustToxLoss(1, FALSE)
		M.losebreath++
		. = TRUE
	..()
