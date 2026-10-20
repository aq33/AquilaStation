/// Used by vassals
/datum/action/vampire/recuperate
	name = "Krwawa regeneracja"
	desc = "Powoli leczy cię krwią twojego pana w zamian za część twojej własnej krwi i wysiłek."
	button_icon_state = "power_recup"
	power_explanation = "Aktywacja tej mocy zaczyna leczyć twoje rany.\n\
		Leczysz obrażenia fizyczne i toksyczne kosztem wytrzymałości i krwi.\n\
		Jeśli twoja rasa ma krew, leczysz dodatkowo oparzenia."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	special_flags = NONE
	vitaecost = 1.5
	cooldown_time = 10 SECONDS

/datum/action/vampire/recuperate/can_use()
	. = ..()
	if(!.)
		return FALSE

	if(owner.stat >= DEAD || owner.incapacitated())
		owner.balloon_alert(owner, "jesteś obezwładniony...")
		return FALSE

	var/mob/living/living_owner = owner
	if(!HAS_TRAIT(owner, TRAIT_NO_BLOOD) && living_owner.blood_volume <= BLOOD_VOLUME_OKAY)
		owner.balloon_alert(owner, "za mało krwi!")
		return FALSE

/datum/action/vampire/recuperate/activate_power()
	. = ..()
	to_chat(owner, span_notice("Twoje mięśnie się napinają, gdy nieśmiertelna krew twojego pana miesza się z twoją i zasklepia rany."))
	owner.balloon_alert(owner, "regeneracja włączona.")

/datum/action/vampire/recuperate/use_power()
	. = ..()
	if(!. || !currently_active)
		return

	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	carbon_owner.set_jitter_if_lower(10 SECONDS)
	carbon_owner.adjustStaminaLoss(vitaecost * 1.1)
	carbon_owner.adjustBruteLoss(-2.5)
	carbon_owner.adjustToxLoss(-2, forced = TRUE)
	// Plasmamen won't lose blood, they don't have any, so they don't heal from Burn.
	if(!HAS_TRAIT(carbon_owner, TRAIT_NO_BLOOD))
		carbon_owner.blood_volume -= vitaecost
		carbon_owner.adjustFireLoss(-1.5)
	// Stop Bleeding
	if(istype(carbon_owner) && carbon_owner.is_bleeding())
		carbon_owner.cauterise_wounds(-0.5)

/datum/action/vampire/recuperate/continue_active()
	if(owner.stat == DEAD)
		return FALSE
	if(owner.incapacitated())
		owner.balloon_alert(owner, "zbyt wyczerpany...")
		return FALSE
	var/mob/living/living_owner = owner
	if(!HAS_TRAIT(owner, TRAIT_NO_BLOOD) && living_owner.blood_volume <= BLOOD_VOLUME_OKAY)
		owner.balloon_alert(owner, "za mało krwi!")
		return FALSE
	return TRUE

/datum/action/vampire/recuperate/deactivate_power()
	owner.balloon_alert(owner, "regeneracja wyłączona.")
	return ..()
