

/datum/symptom/acute/blindness
	name = "Hyphema"
	desc = "Sufferers exhibit dangerously low levels of frames per second in the eyes, leading to damage and eventually blindness."
	max_multiplier = 4
	stage = 2
	badness = EFFECT_DANGER_HARMFUL
	severity = 3

/datum/symptom/acute/blindness/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	var/obj/item/organ/eyes/eyes = mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return // can't do much

	switch(round(multiplier))
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(mob, span_boldwarning("Your eyes burn!"))
			mob.set_eye_blur_if_lower(10 SECONDS)
			eyes.applyOrganDamage(1 * power)

		else
			mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.applyOrganDamage(5 * power)

			// Applies nearsighted at minimum
			if(!HAS_TRAIT(mob, TRAIT_NEARSIGHT) && eyes.damage <= eyes.low_threshold)
				eyes.setOrganDamage(eyes.low_threshold)

			if(prob(eyes.damage - eyes.low_threshold + 1))
				if(!mob.eye_blind)
					to_chat(mob, span_userdanger("You go blind!"))
					eyes.applyOrganDamage(eyes.maxHealth)
			else
				to_chat(mob, span_userdanger("Your eyes burn horrifically!"))
