/datum/symptom/acute/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	max_multiplier = 8
	stage = 3
	max_chance = 33
	severity = 0
	badness = EFFECT_DANGER_HELPFUL
	var/passive_message = span_notice("You feel tingling on your skin as light passes over it.")
	COOLDOWN_DECLARE(heal_msg_cooldown)

/datum/symptom/acute/darkness/activate(mob/living/mob, datum/disease/acute/disease)
	. = ..()
	switch(round(multiplier))
		if(4, 5, 6, 7, 8)
			if(!CanHeal(mob))
				return
			if(mob.getBruteLoss() || mob.getFireLoss())
				to_chat(mob, passive_message)
			Heal(mob, multiplier)
		else
			multiplier = min(multiplier + 0.1, max_multiplier)

/datum/symptom/acute/darkness/proc/CanHeal(mob/living/carbon/mob)
	if(isturf(mob.loc)) //else, there's considered to be no light
		var/turf/mob_turf = mob.loc
		if(mob_turf.is_softly_lit())
			return TRUE
		var/light_amount = min(1, mob_turf.get_lumcount()) - 0.5
		// AQ: nie mamy SHADOW_SPECIES_DIM_LIGHT, bierzemy nasz prog przycmionego swiatla
		if(light_amount > 0.2)
			return FALSE
	return TRUE

/datum/symptom/acute/darkness/proc/Heal(mob/living/carbon/victim, actual_power)
	var/old_health = victim.health
	victim.heal_overall_damage(brute = actual_power * 2, burn = actual_power)
	if(victim.health > old_health && COOLDOWN_FINISHED(src, heal_msg_cooldown))
		to_chat(victim, span_notice("The darkness soothes and mends your wounds."))
		COOLDOWN_START(src, heal_msg_cooldown, 25 SECONDS)
	return TRUE
