// AQUILA - Ciecze, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_effect.dm, master 6a4365b)
// Różnice: bitmaska Aquili (paradise_struktury/smoothing.dm) zamiast SMOOTH_BITMASK, poślizg w biegu (sprint rzuca dalej, handle_slip),
// podpalanie gorącym przedmiotem (klik i wejście), examine po polsku, cenzura moczu jako amoniaku, wygląd i poślizg lodu (nowe).

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
	/// Głębokość do examine (kałuża nie ma osobnego dopisku). Gotowe teksty bez szablonów, żeby działał tłumacz czatu.
	var/static/list/liquid_depth_texts = list(
		"[LIQUID_STATE_ANKLES]" = "<span class='warning'>po kostki</span>",
		"[LIQUID_STATE_WAIST]" = "<span class='warning'>po pas</span>",
		"[LIQUID_STATE_SHOULDERS]" = "<span class='warning'>po ramiona</span>",
		"[LIQUID_STATE_FULLTILE]" = "<span class='danger'>ponad głowę</span>",
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
	RegisterSignal(my_turf, COMSIG_PARENT_ATTACKBY, PROC_REF(turf_attackby))

	// Plamy wody i lodu pod kałużą zastępuje sama kałuża
	SEND_SIGNAL(my_turf, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER, TRUE) // tylko woda: siła 5 suszyła też stały lód (permafrost) lodowych podłóg

	// Plamy i ślady na kaflu kałuża zmywa i wchłania (także te z mapy; kałuża postawiona na mapie niczego nie zmywa)
	if(!mapload)
		wash_decals()

	if(z)
		queue_smooth(src)
		queue_smooth_liquid_neighbors()

/obj/effect/abstract/liquid_turf/Destroy(force)
	if(!isnull(my_turf))
		UnregisterSignal(my_turf, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_EXAMINE, COMSIG_PARENT_ATTACKBY))
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

/// Ile krwi oddaje kałuży krwawa plama albo ślad (plamy krwi nie trzymają reagentów, tylko bloodiness)
#define LIQUID_WASHED_BLOOD_PER_DECAL 2
/// Ile wariantów kształtu ma samotny kafel kałuży (stany puddle-N w liquid.dmi)
#define LIQUID_LONE_PUDDLE_VARIANTS 4

/**
 * AQUILA - kałuża wchodząca na kafel zmywa z niego plamy i ślady (wszystko, co zmywa woda: is_cleanable()).
 * Reagenty plamy (popiół, olej, wnętrzności) trafiają do kałuży, a krwawe plamy i ślady oddają trochę krwi
 * z DNA i grupą krwi plamy oraz jej chorobami (komponent infective), żeby próbka z kałuży mówiła to samo co plama.
 * Tylko przy wejściu na kafel: krew w kałuży sama robi plamę pod sobą (reaction_turf), więc zbieranie każdej
 * nowej plamy pompowałoby krew w kałużę bez końca.
 * Bez process_group(): to się dzieje w Initialize kafla, a grupę i tak przeliczy SSliquids.
 */
/obj/effect/abstract/liquid_turf/proc/wash_decals()
	if(QDELETED(liquid_group) || QDELETED(my_turf))
		return
	var/anything_washed = FALSE
	for(var/obj/effect/decal/cleanable/decal in my_turf)
		if(QDELETED(decal) || !is_cleanable(decal))
			continue
		if(decal.reagents?.total_volume)
			liquid_copy_reagents(decal.reagents, liquid_group.reagents)
		if(istype(decal, /obj/effect/decal/cleanable/blood) && decal.blood_state == BLOOD_STATE_HUMAN)
			liquid_group.reagents.add_reagent(/datum/reagent/blood, LIQUID_WASHED_BLOOD_PER_DECAL, washed_blood_data(decal), liquid_group.reagents.chem_temp, no_react = TRUE)
		anything_washed = TRUE
		qdel(decal)
	if(!anything_washed)
		return
	liquid_group.update_volume_cache()
	liquid_group.handle_visual_changes()

/// Dane krwi ze zmywanej plamy: pierwsze DNA z plamy i jej choroby (kopie)
/obj/effect/abstract/liquid_turf/proc/washed_blood_data(obj/effect/decal/cleanable/decal)
	var/list/data = list("viruses" = list(), "blood_DNA" = null, "blood_type" = null, "resistances" = null, "trace_chem" = null, "mind" = null, "ckey" = null, "gender" = null, "real_name" = null, "cloneable" = null, "factions" = null, "quirks" = null)
	var/list/dna = decal.return_blood_DNA()
	if(length(dna))
		var/dna_key = dna[1]
		data["blood_DNA"] = dna_key
		data["blood_type"] = dna[dna_key]
	for(var/datum/component/infective/infection in decal.GetComponents(/datum/component/infective)) // bez "as anything": GetComponents zwraca list(null), gdy komponentu nie ma
		for(var/datum/disease/disease as anything in infection.diseases)
			data["viruses"] += disease.Copy()
	return data

/// Samotny kafel kałuży (bez sąsiednich kałuż) dostaje nieregularny kształt zamiast zaokrąglonego kwadratu
/obj/effect/abstract/liquid_turf/bitmask_smoothed()
	. = ..()
	if(!my_turf)
		return
	for(var/turf/neighbor as anything in RANGE_TURFS(1, my_turf))
		if(neighbor != my_turf && !QDELETED(neighbor.liquids))
			return
	icon_state = "puddle-[(my_turf.x + my_turf.y * 3) % LIQUID_LONE_PUDDLE_VARIANTS + 1]"

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
	// Gęsta ciecz (krew) leży plamą bez fali: pełne kafelki nakładek głębokości dawały czerwony kwadrat
	if(number > 0 && !liquid_group?.is_viscous())
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
		// Chodem bez poślizgu (NO_SLIP_WHEN_WALKING), w biegu poślizg, w sprincie handle_slip rzuca jeszcze kafel dalej
		// Chód sprawdzamy już tutaj, bo carbon/slip() zapisuje log „slipped on” jeszcze przed odrzuceniem chodu w handle_slip
		if(iscarbon(L) && liquid_group.slippery && L.m_intent != MOVE_INTENT_WALK && !(L.movement_type & FLYING) && (L.mobility_flags & MOBILITY_STAND))
			var/mob/living/carbon/C = L
			C.slip(3 SECONDS, T, NO_SLIP_WHEN_WALKING, 0, TRUE)
		if(!(L.movement_type & FLYING) && ishuman(L))
			var/mob/living/carbon/human/stepped_human = L
			if(!((stepped_human.wear_suit?.body_parts_covered | stepped_human.w_uniform?.body_parts_covered | stepped_human.shoes?.body_parts_covered) & FEET))
				liquid_group.expose_atom(stepped_human, 0.1, TOUCH)

	if(!fire_state)
		try_ignite(get_carried_heat(AM))
	if(fire_state)
		AM.fire_act((T20C+50) + (50*fire_state), 125)

/// AQUILA - temperatura ognia, który coś wnosi do kałuży: płonący mob, gorący przedmiot w ręce albo wrzucony
/obj/effect/abstract/liquid_turf/proc/get_carried_heat(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		return I.is_hot()
	if(!isliving(AM))
		return 0
	var/mob/living/L = AM
	if(L.on_fire)
		return FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100
	. = 0
	for(var/obj/item/held in L.held_items)
		. = max(., held.is_hot())

/// AQUILA - podpala palną kałużę (paliwo, alkohol, olej). Zwraca TRUE, gdy się zapaliła.
/// AQUILA - płomień z wybuchu i inne hotspoty, które nie wołają hotspot_expose kafla, wołają fire_act na zawartości
/obj/effect/abstract/liquid_turf/fire_act(exposed_temperature, exposed_volume)
	try_ignite(exposed_temperature)

/obj/effect/abstract/liquid_turf/proc/try_ignite(heat)
	if(fire_state || heat < FIRE_MINIMUM_TEMPERATURE_TO_EXIST || QDELETED(liquid_group) || liquid_group.frozen)
		return FALSE
	var/datum/gas_mixture/air = my_turf.return_air()
	if(!air || air.get_moles(GAS_O2) < 0.5 || air.get_moles(GAS_HYPERNOB) > REACTION_OPPRESSION_THRESHOLD) // jak w hotspot_expose
		return FALSE
	liquid_group.ignite_turf(my_turf)
	return fire_state != LIQUID_FIRE_STATE_NONE

/// AQUILA - kliknięcie kafla z kałużą gorącym przedmiotem (zapalniczka, spawarka, papieros) ją podpala
/obj/effect/abstract/liquid_turf/proc/turf_attackby(datum/source, obj/item/I, mob/user, params)
	SIGNAL_HANDLER
	if(!try_ignite(I.is_hot()))
		return
	user.visible_message("<span class='danger'>[user] podpala ciecz na podłodze za pomocą [I]!</span>", "<span class='danger'>Podpalasz ciecz na podłodze za pomocą [I]!</span>")
	log_game("[key_name(user)] ignited a liquid puddle with [I] at [AREACOORD(my_turf)]")
	return COMPONENT_NO_AFTERATTACK

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
		if(C.stat == DEAD || C.is_mouth_covered()) // maska albo szczelny hełm; martwy nie łyka
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
	if(istype(reagent, /datum/reagent/ammonia/urine) && viewer?.censors_bodily_functions())
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

	var/depth = liquid_depth_texts["[liquid_group.group_overlay_state]"] // null = kałuża
	var/member_count = max(1, length(liquid_group.members))

	if(examiner.can_see_reagents())
		if(length(liquid_group.reagents.reagent_list) == 1)
			var/datum/reagent/reagent_type = liquid_group.reagents.reagent_list[1]
			var/volume = round(reagent_type.volume / member_count, 0.01)
			var/reagent_name = reagent_name_for(reagent_type, examiner)
			if(depth)
				examine_list += "<span class='notice'>Jest tu [volume] j. [reagent_name], [depth].</span>"
			else
				examine_list += "<span class='notice'>Jest tu kałuża: [volume] j. [reagent_name].</span>"
		else
			if(depth)
				examine_list += "<span class='notice'>Jest tu mieszanina, [depth]. Skład:</span>"
			else
				examine_list += "<span class='notice'>Jest tu kałuża mieszaniny. Skład:</span>"
			for(var/datum/reagent/reagent_type as anything in liquid_group.reagents.reagent_list)
				var/volume = round(reagent_type.volume / member_count, 0.01)
				var/reagent_name = reagent_name_for(reagent_type, examiner)
				examine_list += "&bull; [volume] j. [reagent_name]"
		examine_list += "<span class='notice'>Temperatura cieczy: [round(liquid_group.group_temperature, 0.1)] K.</span>"
		return

	if(depth)
		examine_list += "<span class='notice'>Jest tu ciecz, [depth].</span>"
	else
		examine_list += "<span class='notice'>Jest tu kałuża.</span>"

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

#undef LIQUID_WASHED_BLOOD_PER_DECAL
#undef LIQUID_LONE_PUDDLE_VARIANTS
