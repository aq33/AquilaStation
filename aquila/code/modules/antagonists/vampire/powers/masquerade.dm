/datum/action/vampire/masquerade
	name = "Maskarada"
	desc = "Udawaj oznaki życia śmiertelnika i umknij uwadze zarówno przypadkowych gapiów, jak i lekarzy, choć naprawdę jesteś potworem."
	button_icon_state = "power_human"
	power_explanation = "Maskarada podrabia twoją tożsamość tak, że jest praktycznie nie do odróżnienia od ludzkiej.\n\
		Tracisz prawie wszystkie wampirze korzyści, w tym bierne leczenie.\n\
		Zyskujesz sekwencję genetyczną, a analizator zdrowia pokaże u ciebie 100% krwi.\n\
		Przy oględzinach nie będziesz wyglądać na bladego. Niczego ponad bladość to jednak nie ukryje.\n\
		Po wyłączeniu Maskarady odzyskasz wampirze zdolności i stracisz wszystkie choroby oraz mutacje, których się nabawiłeś."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_DURING_SOL | BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED
	vitaecost = 15
	cooldown_time = 5 SECONDS
	constant_vitaecost = 0.5

/datum/action/vampire/masquerade/activate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "Maskarada włączona.")
	carbon_owner.apply_status_effect(/datum/status_effect/masquerade)

/datum/action/vampire/masquerade/deactivate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "Maskarada wyłączona.")
	carbon_owner.remove_status_effect(/datum/status_effect/masquerade)

/datum/status_effect/masquerade
	id = "masquerade"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/masquerade

/atom/movable/screen/alert/status_effect/masquerade
	name = "Maskarada"
	desc = "Ukrywasz swoją tożsamość mocą Maskarady. Wstrzymuje to wampirze leczenie."
	icon = 'aquila/icons/vampires/actions_vampire.dmi'
	icon_state = "masquerade_alert"
	alerttooltipstyle = "cult"

/datum/status_effect/masquerade/on_apply()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return

	// Handle Traits
	carbon_owner.remove_traits(vampiredatum.vampire_traits, TRAIT_VAMPIRE)
	ADD_TRAIT(carbon_owner, TRAIT_MASQUERADE, TRAIT_VAMPIRE)

	// Handle organs
	var/obj/item/organ/heart/vampheart = carbon_owner.get_organ_by_type(/obj/item/organ/heart)
	vampheart?.Restart()
	var/obj/item/organ/eyes/eyes = carbon_owner.get_organ_by_type(/obj/item/organ/eyes)
	eyes?.flash_protect = initial(eyes.flash_protect)

	to_chat(carbon_owner, span_notice("Twoje serce fałszywie bije w martwej piersi. Możesz jeszcze uchodzić za śmiertelnika."))
	to_chat(carbon_owner, span_warning("Udając życie, nie leczysz się jak wampir."))

/datum/status_effect/masquerade/on_remove()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return

	// Clear mutations and diseases
	carbon_owner.dna.remove_all_mutations()
	for(var/datum/disease/diseases in carbon_owner.diseases)
		diseases.cure()

	// Handle Traits
	carbon_owner.add_traits(vampiredatum.vampire_traits, TRAIT_VAMPIRE)
	REMOVE_TRAIT(carbon_owner, TRAIT_MASQUERADE, TRAIT_VAMPIRE)

	// Handle organs
	var/obj/item/organ/heart/vampheart = carbon_owner.get_organ_slot(ORGAN_SLOT_HEART)
	vampheart?.Stop()
	var/obj/item/organ/eyes/eyes = carbon_owner.get_organ_slot(ORGAN_SLOT_EYES)
	eyes?.flash_protect = max(initial(eyes.flash_protect) - 1, - 1)

	to_chat(carbon_owner, span_notice("Twoje serce uderza ostatni raz, skóra wysycha i wraca lodowata bladość."))
