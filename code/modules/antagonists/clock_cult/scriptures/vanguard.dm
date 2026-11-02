/datum/clockcult/scripture/slab/vanguard
	name = "Awangarda"
	use_time = 300
	slab_overlay = "vanguard"
	desc = "Daje ci 30 sekund odporności na ogłuszenie, ale w tym czasie nie możesz przywoływać innych zaklęć."
	tip = "Daje chwilową odporność na pałki i disablery."
	invokation_time = 10
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 150
	var/last_recorded_stam_dam = 0
	var/total_stamina_damage = 0

/datum/clockcult/scripture/slab/vanguard/click_on(atom/A)
	return FALSE

/datum/clockcult/scripture/slab/vanguard/invoke_success()
	ADD_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	to_chat(invoker, "<span class='sevtug'>Czujesz, że nic cię nie powstrzyma!</span>")

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 50)
		to_chat(invoker, "<span class='sevtug'>Znów zaczynasz czuć zmęczenie.</span>")

/datum/clockcult/scripture/slab/vanguard/end_invoke()
	REMOVE_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_CONFUSEIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOSTAMCRIT, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	..()
