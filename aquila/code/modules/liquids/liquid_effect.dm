// AQUILA - Ciecze, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_effect.dm, master 6a4365b)
// Różnice: bitmaska Aquili (paradise_struktury/smoothing.dm) zamiast SMOOTH_BITMASK, poślizg przez is_sprinting(),
// examine po polsku, cenzura moczu jako amoniaku, wygląd i poślizg lodu (nowe).

/obj/effect/abstract/liquid_turf
	name = "ciecz"
	icon = 'aquila/icons/obj/effects/liquid.dmi'
	icon_state = "water-0"
	base_icon_state = "water"
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	color = "#DDF"
	alpha = 175
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
	smooth = SMOOTH_TRUE
	bitmask_smooth = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/datum/liquid_group/liquid_group
	var/turf/my_turf

	var/fire_state = LIQUID_FIRE_STATE_NONE
	var/liquid_state = LIQUID_STATE_PUDDLE
	var/no_effects = FALSE
	/// AQUILA - kafel zamarzniętej grupy
	var/frozen = FALSE

	var/static/obj/effect/abstract/liquid_fire/small/small_fire
	var/static/obj/effect/abstract/liquid_fire/medium/medium_fire
	var/static/obj/effect/abstract/liquid_fire/big/big_fire
	var/static/list/depth_overlays = list()
	var/static/mutable_appearance/ice_overlay

	var/obj/effect/abstract/liquid_fire/displayed_content
	/// Opisy poziomów do examine (fragment przed nazwą cieczy, poziom za nią)
	var/static/list/liquid_state_messages = list(
		"[LIQUID_STATE_PUDDLE]" = "Jest tu kałuża: $.",
		"[LIQUID_STATE_ANKLES]" = "Jest tu $, <span class='warning'>po kostki</span>.",
		"[LIQUID_STATE_WAIST]" = "Jest tu $, <span class='warning'>po pas</span>.",
		"[LIQUID_STATE_SHOULDERS]" = "Jest tu $, <span class='warning'>po ramiona</span>.",
		"[LIQUID_STATE_FULLTILE]" = "Jest tu $, <span class='danger'>ponad głowę</span>.",
	)

	var/temporary_split_key

/obj/effect/abstract/liquid_turf/Initialize(mapload, datum/liquid_group/group_to_add)
	. = ..()
	if(!small_fire)
		small_fire = new
	if(!medium_fire)
		medium_fire = new
	if(!big_fire)
		big_fire = new

	my_turf ||= loc

	if(!isturf(my_turf))
		return INITIALIZE_HINT_QDEL

	if(SEND_SIGNAL(my_turf, COMSIG_TURF_LIQUIDS_CREATION, src) & BLOCK_LIQUID_CREATION)
		return INITIALIZE_HINT_QDEL

	if(QDELETED(my_turf.liquids))
		my_turf.liquids = src

	if(!QDELETED(group_to_add))
		group_to_add.add_to_group(my_turf)
		set_new_liquid_state(liquid_group.group_overlay_state)

	if(QDELETED(liquid_group) && QDELETED(group_to_add))
		liquid_group = new(1, src)

	RegisterSignal(my_turf, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(my_turf, COMSIG_PARENT_EXAMINE, PROC_REF(examine_turf))

	// Plamy wody i lodu pod kałużą zastępuje sama kałuża
	SEND_SIGNAL(my_turf, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER | TURF_WET_ICE, TRUE)

	if(z)
		queue_smooth(src)
		queue_smooth_liquid_neighbors()

/obj/effect/abstract/liquid_turf/Destroy(force)
	if(!isnull(my_turf))
		UnregisterSignal(my_turf, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_EXAMINE))
		liquid_group?.remove_from_group(my_turf)
		SSliquids.evaporation_queue -= my_turf
		SSliquids.burning_turfs -= my_turf
		SSliquids.cached_exposures -= my_turf
		if(my_turf.liquids == src)
			my_turf.liquids = null
		queue_smooth_liquid_neighbors()
	if(displayed_content)
		vis_contents -= displayed_content
		displayed_content = null
	liquid_group = null
	my_turf = null
	return ..()

/// Przelicza wygląd sąsiednich kałuż (bez przeliczania ścian i okien jak queue_smooth_neighbors)
/obj/effect/abstract/liquid_turf/proc/queue_smooth_liquid_neighbors()
	var/turf/center = my_turf || get_turf(src)
	if(!center)
		return
	for(var/turf/neighbor as anything in RANGE_TURFS(1, center))
		if(!QDELETED(neighbor.liquids) && neighbor.liquids != src)
			queue_smooth(neighbor.liquids)

/obj/effect/abstract/liquid_turf/bitmask_connects_to(turf/T)
	if(!T)
		return FALSE
	if(!QDELETED(T.liquids))
		return TRUE
	if(isclosedturf(T))
		return TRUE
	for(var/obj/structure/window/W in T)
		if(W.fulltile)
			return TRUE
	return FALSE

/obj/effect/abstract/liquid_turf/proc/process_evaporation()
	if(liquid_group.frozen || (!liquid_group.always_evaporates && (liquid_group.expected_turf_height > LIQUID_ANKLES_LEVEL_HEIGHT)))
		SSliquids.evaporation_queue -= my_turf
		return

	//See if any of our reagents evaporates
	var/any_change = FALSE
	var/always_evaporates = liquid_group.always_evaporates
	var/evaporation_multiplier = liquid_group.evaporation_multiplier
	var/turf/our_turf = my_turf
	for(var/datum/reagent/R as anything in liquid_group.reagents.reagent_list)
		//We evaporate. bye bye
		if(R.evaporates || always_evaporates)
			var/remove_amount = min(R.evaporation_rate * evaporation_multiplier, R.volume, (liquid_group.reagents_per_turf / length(liquid_group.reagents.reagent_list)))
			var/reagent_type = R.type
			R.evaporate(our_turf, remove_amount)
			liquid_group.remove_specific(src, remove_amount, reagent_type, TRUE)
			any_change = TRUE
			if(QDELETED(src) || QDELETED(liquid_group))
				return

	if(!any_change)
		SSliquids.evaporation_queue -= my_turf
		return

/obj/effect/abstract/liquid_turf/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	if(harderforce)
		. = ..()

/obj/effect/abstract/liquid_turf/proc/set_new_liquid_state(new_state)
	if(no_effects)
		return
	liquid_state = new_state
	update_liquid_overlays()
	queue_smooth(src)

/obj/effect/abstract/liquid_turf/proc/update_liquid_overlays()
	cut_overlays()
	var/number = liquid_state - 1
	if(number > 0)
		var/list/stage_overlays = depth_overlays["[number]"]
		if(!stage_overlays)
			// Dół fali przykrywa nogi moba, góra leży pod mobami
			stage_overlays = list(
				mutable_appearance('aquila/icons/obj/effects/liquid_overlays.dmi', "stage[number]_bottom", ABOVE_MOB_LAYER, GAME_PLANE),
				mutable_appearance('aquila/icons/obj/effects/liquid_overlays.dmi', "stage[number]_top", BELOW_MOB_LAYER, GAME_PLANE),
			)
			depth_overlays["[number]"] = stage_overlays
		add_overlay(stage_overlays)
	if(frozen)
		if(!ice_overlay)
			ice_overlay = mutable_appearance('icons/effects/water.dmi', "ice_floor")
			ice_overlay.appearance_flags = RESET_ALPHA
		add_overlay(ice_overlay)

/obj/effect/abstract/liquid_turf/proc/set_frozen(new_frozen)
	if(frozen == new_frozen)
		return
	frozen = new_frozen
	name = frozen ? "lód" : initial(name)
	update_liquid_overlays()

/obj/effect/abstract/liquid_turf/proc/set_fire_effect()
	if(displayed_content)
		vis_contents -= displayed_content

	if(!liquid_group)
		return

	switch(liquid_group.group_fire_state)
		if(LIQUID_FIRE_STATE_SMALL, LIQUID_FIRE_STATE_MILD)
			displayed_content = small_fire
		if(LIQUID_FIRE_STATE_MEDIUM)
			displayed_content = medium_fire
		if(LIQUID_FIRE_STATE_HUGE, LIQUID_FIRE_STATE_INFERNO)
			displayed_content = big_fire
		else
			displayed_content = null

	if(displayed_content && fire_state)
		vis_contents |= displayed_content
		set_light(3, 1, LIGHT_COLOR_FIRE)
	else
		set_light(0)

//Takes a flat of our reagents and returns it, possibly qdeling our liquids
/obj/effect/abstract/liquid_turf/proc/take_reagents_flat(flat_amount)
	liquid_group.remove_any(src, flat_amount)

/obj/effect/abstract/liquid_turf/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!liquid_group)
		qdel(src)
		return

	var/turf/T = source
	if(isobserver(AM) || iseffect(AM) || isprojectile(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy

	if(liquid_group.frozen)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(!(C.movement_type & (FLYING|FLOATING)))
				C.slip(0, T, SLIDE_ICE | GALOSHES_DONT_HELP)
		return

	if(liquid_group.group_overlay_state >= LIQUID_STATE_ANKLES)
		if(prob(30))
			var/sound_to_play = pick(list(
				'aquila/sound/effects/water_wade1.ogg',
				'aquila/sound/effects/water_wade2.ogg',
				'aquila/sound/effects/water_wade3.ogg',
				'aquila/sound/effects/water_wade4.ogg'
				))
			playsound(T, sound_to_play, 50, 0)
		if(isliving(AM))
			var/mob/living/L = AM
			L.apply_status_effect(/datum/status_effect/water_affected)
			liquid_group.expose_atom(L, 1, TOUCH)
	else if(isliving(AM))
		var/mob/living/L = AM
		if(iscarbon(L) && liquid_group.slippery && L.is_sprinting() && !(L.movement_type & FLYING) && (L.mobility_flags & MOBILITY_STAND))
			var/mob/living/carbon/C = L
			C.slip(3 SECONDS, T, NO_SLIP_WHEN_WALKING, 0, TRUE)
		if(!(L.movement_type & FLYING) && ishuman(L))
			var/mob/living/carbon/human/stepped_human = L
			if(!((stepped_human.wear_suit?.body_parts_covered | stepped_human.w_uniform?.body_parts_covered | stepped_human.shoes?.body_parts_covered) & FEET))
				liquid_group.expose_atom(stepped_human, 0.1, TOUCH)

	if(fire_state)
		AM.fire_act((T20C+50) + (50*fire_state), 125)

/// Upadek z piętra w ciecz (Monke: COMSIG_TURF_MOB_FALL)
/obj/effect/abstract/liquid_turf/proc/mob_fall(mob/living/M)
	var/turf/T = my_turf
	if(!liquid_group || liquid_group.frozen || !T.has_gravity())
		return

	if(liquid_group.group_overlay_state == LIQUID_STATE_PUDDLE)
		liquid_group.expose_atom(M, 1, TOUCH)
		return
	playsound(T, 'aquila/sound/effects/splash_loud.ogg', 50, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.wear_mask && C.wear_mask.flags_cover & MASKCOVERSMOUTH)
			to_chat(C, "<span class='userdanger'>Wpadasz do cieczy!</span>")
		else
			liquid_group.transfer_to_atom(src, CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT, C)
			C.adjustOxyLoss(5)
			INVOKE_ASYNC(C, TYPE_PROC_REF(/mob, emote), "cough")
			to_chat(C, "<span class='userdanger'>Wpadasz do cieczy i łykasz trochę!</span>")
	else
		to_chat(M, "<span class='userdanger'>Wpadasz do cieczy!</span>")

/// Nazwa reagentu w kałuży dla danego widza (cenzura pokazuje mocz jako amoniak)
/obj/effect/abstract/liquid_turf/proc/reagent_name_for(datum/reagent/reagent, mob/viewer)
	if(istype(reagent, /datum/reagent/ammonia/urine) && viewer?.client?.prefs?.hide_bodily_functions)
		var/datum/reagent/ammonia/ammonia_type = /datum/reagent/ammonia
		return initial(ammonia_type.name)
	return reagent.name

/obj/effect/abstract/liquid_turf/proc/examine_turf(turf/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if(!liquid_group)
		qdel(src)
		return

	if(!length(liquid_group.reagents.reagent_list))
		return

	if(liquid_group.frozen)
		examine_list += "<span class='notice'>Ciecz na podłodze zamarzła w śliski lód.</span>"

	var/liquid_state_template = liquid_state_messages["[liquid_group.group_overlay_state]"]
	var/member_count = max(1, length(liquid_group.members))

	if(examiner.can_see_reagents())
		if(length(liquid_group.reagents.reagent_list) == 1)
			var/datum/reagent/reagent_type = liquid_group.reagents.reagent_list[1]
			var/volume = round(reagent_type.volume / member_count, 0.01)
			examine_list += "<span class='notice'>[replacetext(liquid_state_template, "$", "[volume] j. [reagent_name_for(reagent_type, examiner)]")]</span>"
		else
			examine_list += "<span class='notice'>[replacetext(liquid_state_template, "$", "mieszanina")] Skład:</span>"
			for(var/datum/reagent/reagent_type as anything in liquid_group.reagents.reagent_list)
				var/volume = round(reagent_type.volume / member_count, 0.01)
				examine_list += "&bull; [volume] j. [reagent_name_for(reagent_type, examiner)]"
		examine_list += "<span class='notice'>Temperatura cieczy: [round(liquid_group.group_temperature, 0.1)] K.</span>"
		return

	examine_list += "<span class='notice'>[replacetext(liquid_state_template, "$", "ciecz")]</span>"

/obj/effect/temp_visual/liquid_splash
	icon = 'aquila/icons/obj/effects/splash.dmi'
	icon_state = "splash"
	layer = FLY_LAYER
	randomdir = FALSE

/obj/effect/abstract/liquid_fire
	icon = 'aquila/icons/obj/effects/liquid.dmi'
	plane = GAME_PLANE
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | RESET_ALPHA
	vis_flags = VIS_INHERIT_PLANE

/obj/effect/abstract/liquid_fire/small
	icon_state = "fire_small"

/obj/effect/abstract/liquid_fire/medium
	icon_state = "fire_medium"

/obj/effect/abstract/liquid_fire/big
	icon_state = "fire_big"
