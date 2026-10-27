// AQUILA - Dym i zapachy, port z Monkestation 2.0 (monkestation/code/modules/pollution/)
/turf/open
	/// Smoke and smells hanging over this tile, see aquila/code/modules/pollution/
	var/datum/pollution/pollution

/datum/pollution
	/// Reference to the turf we're on
	var/turf/open/my_turf
	/// List of all pollutant types to their amount
	var/list/pollutants = list()
	/// Total amount
	var/total_amount = 0
	/// Height of the pollution, used to create a sandpiling effect
	var/height = 0
	/// The vis content we are managing
	var/obj/effect/abstract/pollution/managed_overlay

/datum/pollution/New(turf/open/passed_turf)
	if(!isopenturf(passed_turf))
		stack_trace("Attempted to create a pollution datum on a non-open turf ([passed_turf?.type || null])")
		qdel(src)
		return
	. = ..()
	my_turf = passed_turf
	my_turf.pollution = src
	REGISTER_POLLUTION(src)

/datum/pollution/Destroy()
	if(managed_overlay)
		UnregisterSignal(managed_overlay, COMSIG_PARENT_QDELETING)
		QDEL_NULL(managed_overlay)
	SET_UNACTIVE_POLLUTION(src)
	UNREGISTER_POLLUTION(src)
	if(my_turf?.pollution == src)
		my_turf.pollution = null
	my_turf = null
	return ..()

/datum/pollution/proc/on_managed_overlay_deleted(datum/source)
	SIGNAL_HANDLER
	if(source != managed_overlay)
		return
	UnregisterSignal(managed_overlay, COMSIG_PARENT_QDELETING)
	managed_overlay = null

/datum/pollution/proc/touch_act(mob/living/carbon/victim)
	if(!victim.can_inject())
		return
	var/list/singleton_cache = SSpollution.singletons
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_TOUCH_ACT))
			continue
		var/amount = pollutants[type]
		pollutant.touch_act(victim, amount)

/datum/pollution/proc/breathe_act(mob/living/carbon/victim)
	var/list/singleton_cache = SSpollution.singletons
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_BREATHE_ACT))
			continue
		var/amount = pollutants[type]
		pollutant.breathe_act(victim, amount)

/// Returns the strongest smell on this tile that is strong enough to notice. Its strength is added to `smell_power`.
/datum/pollution/proc/get_dominant_smell(list/smell_power)
	var/list/singleton_cache = SSpollution.singletons
	var/datum/pollutant/dominant_pollutant
	var/dominiant_smell_power
	for(var/type in pollutants)
		var/datum/pollutant/pollutant = singleton_cache[type]
		if(!(pollutant.pollutant_flags & POLLUTANT_SMELL))
			continue
		var/smelly_power = pollutant.smell_intensity * pollutants[type]
		if(smelly_power < POLLUTANT_SMELL_THRESHOLD)
			continue
		if(!dominant_pollutant || smelly_power > dominiant_smell_power)
			dominant_pollutant = pollutant
			dominiant_smell_power = smelly_power
	if(smell_power && dominant_pollutant)
		smell_power += dominiant_smell_power
	return dominant_pollutant

/// When a user smells this pollution. Returns the smelled pollutant, if any.
/datum/pollution/proc/smell_act(mob/living/sniffer)
	if(HAS_TRAIT(sniffer, TRAIT_AGEUSIA)) // can't taste, can't smell.
		return
	var/list/smell_power = list()
	var/datum/pollutant/dominant_pollutant = get_dominant_smell(smell_power)
	if(!dominant_pollutant)
		return
	var/dominiant_smell_power = smell_power[1]

	var/robotic = (MOB_ROBOTIC in sniffer.mob_biotypes)
	var/smell_string
	switch(dominiant_smell_power)
		if(0 to POLLUTANT_SMELL_NORMAL)
			if(robotic)
				smell_string = "Twoje czujniki wykrywają w powietrzu śladowe ilości [dominant_pollutant.scent]."
			else
				smell_string = "Coś delikatnie łaskocze cię w nos... to chyba [dominant_pollutant.descriptor] [dominant_pollutant.scent]."
		if(POLLUTANT_SMELL_NORMAL to POLLUTANT_SMELL_STRONG)
			if(robotic)
				smell_string = "Twoje czujniki wykrywają w powietrzu obecność [dominant_pollutant.scent]."
			else
				smell_string = "W powietrzu unosi się [dominant_pollutant.descriptor] [dominant_pollutant.scent]."
		if(POLLUTANT_SMELL_STRONG to INFINITY)
			if(robotic)
				smell_string = "Twoje czujniki wykrywają wysokie stężenie [dominant_pollutant.scent]."
			else
				smell_string = "W nozdrza uderza cię nie do pomylenia [dominant_pollutant.descriptor] [dominant_pollutant.scent]!"

	if(dominant_pollutant.descriptor == SCENT_DESC_ODOR)
		to_chat(sniffer, span_warning(smell_string))
	else
		to_chat(sniffer, span_notice(smell_string))
	if(!robotic)
		dominant_pollutant.on_smell(sniffer, dominiant_smell_power)
	return dominant_pollutant

/datum/pollution/proc/scrub_amount(amount_to_scrub, update_active = TRUE, planetary_multiplier = FALSE)
	if(planetary_multiplier && my_turf?.planetary_atmos) //Dissipate faster on planetary atmos
		amount_to_scrub *= POLLUTION_DISSIPATION_PLANETARY_MULTIPLIER
	if(amount_to_scrub >= total_amount || !isopenturf(my_turf))
		qdel(src)
		return
	for(var/type in pollutants)
		pollutants[type] -= amount_to_scrub * pollutants[type] / total_amount
	total_amount -= amount_to_scrub
	update_height()
	handle_overlay()
	if(update_active)
		my_turf.update_adjacent_pollutants()

/datum/pollution/proc/add_pollutant(polutant_type, amount)
	if(!pollutants[polutant_type])
		pollutants[polutant_type] = 0
	pollutants[polutant_type] += amount
	total_amount += amount
	update_height()
	handle_overlay()
	SET_ACTIVE_POLLUTION(src)

/datum/pollution/proc/add_pollutant_list(list/passed_pollutants)
	for(var/polutant_type in passed_pollutants)
		if(!pollutants[polutant_type])
			pollutants[polutant_type] = 0
		pollutants[polutant_type] += passed_pollutants[polutant_type]
		total_amount += passed_pollutants[polutant_type]
	update_height()
	handle_overlay()
	SET_ACTIVE_POLLUTION(src)

/datum/pollution/proc/update_height()
	height = calculate_height(total_amount)

/datum/pollution/proc/calculate_height(passed_amount)
	return CEILING(passed_amount / POLLUTION_HEIGHT_DIVISOR, 1)

/datum/pollution/proc/process_cell()
	if(height <= 1)
		SET_UNACTIVE_POLLUTION(src)
		return
	var/list/sharing_turfs
	var/list/potential_activers
	for(var/turf/open/open_turf in my_turf.atmos_adjacent_turfs)
		if(can_share_with(open_turf))
			LAZYSET(sharing_turfs, open_turf, TRUE)
		else
			LAZYSET(potential_activers, open_turf, TRUE)
	if(!length(sharing_turfs))
		SET_UNACTIVE_POLLUTION(src)
		return
	LAZYSET(sharing_turfs, my_turf, TRUE)
	//Now we've gotten all the turfs that should share pollution. Gather their total pollutions and split evenly
	var/list/total_share_pollutants = list()
	var/total_share_amount = 0
	for(var/turf/open/open_turf as anything in sharing_turfs)
		var/datum/pollution/cached_pollution = open_turf.pollution
		if(QDELETED(cached_pollution))
			continue
		for(var/type in cached_pollution.pollutants)
			if(!total_share_pollutants[type])
				total_share_pollutants[type] = 0
			total_share_pollutants[type] += cached_pollution.pollutants[type]
			total_share_amount += cached_pollution.pollutants[type]

	var/sharing_len = length(sharing_turfs)
	for(var/type in total_share_pollutants)
		total_share_pollutants[type] /= sharing_len
	total_share_amount /= sharing_len
	var/new_heights = calculate_height(total_share_amount)
	for(var/turf/open/open_turf as anything in sharing_turfs)
		// Space takes its share for good
		if(isspaceturf(open_turf))
			continue

		assert_pollution(open_turf)
		var/datum/pollution/cached_pollution = open_turf.pollution

		cached_pollution.pollutants = total_share_pollutants.Copy()
		cached_pollution.total_amount = total_share_amount
		cached_pollution.height = new_heights
		cached_pollution.handle_overlay()
		SET_ACTIVE_POLLUTION(cached_pollution)

	for(var/turf/open/open_turf as anything in potential_activers)
		if(open_turf.pollution?.can_share_with(my_turf))
			SET_ACTIVE_POLLUTION(open_turf.pollution)

/datum/pollution/proc/can_share_with(turf/open/shareto)
	if(!isopenturf(shareto))
		return FALSE
	if(QDELETED(shareto.pollution))
		return TRUE
	if((shareto.pollution.height + 1) < height)
		return TRUE
	return FALSE

/datum/pollution/proc/assert_pollution(turf/open/to_assert)
	if(!isopenturf(to_assert))
		CRASH("Attempted to assert pollution on a non-open turf ([to_assert?.type || null])")
	if(QDELETED(to_assert.pollution))
		new /datum/pollution(to_assert)

/datum/pollution/proc/handle_overlay()
	var/datum/pollutant/pollutant
	var/total_thickness
	var/list/pollutant_cache = SSpollution.singletons
	for(var/pollutant_type in pollutants)
		var/datum/pollutant/iterated_pollutant = pollutant_cache[pollutant_type]
		if(!(iterated_pollutant.pollutant_flags & POLLUTANT_APPEARANCE))
			continue
		var/calc_thickness = pollutants[pollutant_type] * iterated_pollutant.thickness
		if(!pollutant || calc_thickness > total_thickness)
			pollutant = iterated_pollutant
			total_thickness = calc_thickness

	// AQUILA - Monke kept the haze around after the smoke thinned out, we drop it below the threshold
	if(!total_thickness || total_thickness < POLLUTANT_APPEARANCE_THICKNESS_THRESHOLD)
		if(managed_overlay)
			UnregisterSignal(managed_overlay, COMSIG_PARENT_QDELETING)
			QDEL_NULL(managed_overlay)
		return

	if(!managed_overlay)
		managed_overlay = new /obj/effect/abstract/pollution(my_turf)
		RegisterSignal(managed_overlay, COMSIG_PARENT_QDELETING, PROC_REF(on_managed_overlay_deleted))

	managed_overlay.alpha = min(FLOOR(pollutant.alpha * total_thickness * THICKNESS_ALPHA_COEFFICIENT, 1), pollutant.alpha)
	managed_overlay.color = pollutant.color

///Atmos adjacency has been updated on this turf, see if it affects any of our pollutants
/turf/proc/update_adjacent_pollutants()
	for(var/turf/open/open_turf as anything in atmos_adjacent_turfs)
		if(!isopenturf(open_turf) || QDELETED(open_turf.pollution))
			continue
		SET_ACTIVE_POLLUTION(open_turf.pollution)

/// Pollution follows an inherited atmosphere, anything else clears it
/turf/open/ChangeTurf(path, list/new_baseturfs, flags)
	var/datum/pollution/stashed_pollution = pollution
	if(!stashed_pollution)
		return ..()
	if(!(flags & CHANGETURF_INHERIT_AIR) || !ispath(path, /turf/open) || ispath(path, /turf/open/space))
		qdel(stashed_pollution)
		return ..()
	. = ..()
	var/turf/open/new_turf = .
	if(QDELETED(stashed_pollution))
		return
	if(!istype(new_turf))
		qdel(stashed_pollution)
		return
	new_turf.pollution = stashed_pollution
	stashed_pollution.my_turf = new_turf
	stashed_pollution.handle_overlay()

/turf/proc/pollute_turf(pollution_type, amount, cap)
	return

/turf/proc/pollute_turf_list(list/pollutions, cap)
	return

/turf/open/pollute_turf(pollution_type, amount, cap)
	if(QDELETED(pollution))
		pollution = new(src)
	if(cap && pollution.total_amount >= cap)
		return
	pollution.add_pollutant(pollution_type, amount)

/turf/open/pollute_turf_list(list/pollutions, cap)
	if(QDELETED(pollution))
		pollution = new(src)
	if(cap && pollution.total_amount >= cap)
		return
	pollution.add_pollutant_list(pollutions)

/turf/open/space/pollute_turf(pollution_type, amount, cap)
	return

/turf/open/space/pollute_turf_list(list/pollutions, cap)
	return
