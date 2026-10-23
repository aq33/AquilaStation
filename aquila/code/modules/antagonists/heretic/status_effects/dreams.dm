/datum/status_effect/grouped/heretic_dreams
	id = "heretic_dreams"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	/// Cooldown between allowed dreams
	COOLDOWN_DECLARE(dreaming_cooldown)

/**
 * AQUILA - tg dorzuca sen heretyka do puli snów (COMSIG_PRE_DREAMING, waga 200 przy zwykłych 1000).
 * U nas sny to jedna procedura /mob/living/carbon/dream(), więc nadpisanie w _compat/core.dm pyta tutaj,
 * czy zamiast zwykłego snu ma się przyśnić Mansus. Zwraca TRUE, gdy sen heretyka się zaczął.
 */
/datum/status_effect/grouped/heretic_dreams/proc/try_heretic_dream(mob/living/carbon/dreamer)
	if(!COOLDOWN_FINISHED(src, dreaming_cooldown))
		return FALSE
	if(!prob(17))
		return FALSE

	var/atom/dream_center = get_dream_center(dreamer)
	if(isnull(dream_center))
		return FALSE

	var/datum/dream/heretic/heretic_dream = new(dream_center)
	var/list/dream_fragments = heretic_dream.GenerateDream(dreamer)
	qdel(heretic_dream)

	COOLDOWN_START(src, dreaming_cooldown, /datum/mood_event/mansus_dream_fatigue::timeout)
	dreamer.add_mood_event("mansus_dream_fatigue", /datum/mood_event/mansus_dream_fatigue)
	dreamer.dreaming = TRUE
	dreamer.dream_sequence(dream_fragments)
	return TRUE

/datum/status_effect/grouped/heretic_dreams/proc/get_dream_center(mob/living/dreamer)
	// Select a random influence as the center of the dream
	if(length(GLOB.reality_smash_track.smashes))
		return pick(GLOB.reality_smash_track.smashes)

	// If there are no influences, either don't trigger the dream (if we are a heretic) or pick a completely random locale (if we aren't)
	if(IS_HERETIC(dreamer))
		return null

	return get_safe_random_station_turf_equal_weight()

/// Heretics can see dreams about random machinery from the perspective of a random unused influence
/datum/dream/heretic
	/// The location of the influence (or lack thereof in the case of a fake dream) we will be dreaming about
	var/atom/dream_center
	/// The distance to the objects visible from the influence during the dream
	var/dream_view_range = 5
	var/list/what_you_can_see = list(
		/obj/item,
		/obj/structure,
		/obj/machinery,
	)
	var/static/list/what_you_cant_see = typecacheof(list(
		// Underfloor stuff and default wallmounts
		/obj/item/radio/intercom,
		/obj/structure/cable,
		/obj/structure/disposalpipe/segment,
		/obj/machinery/atmospherics/pipe/manifold4w,
		/obj/machinery/atmospherics/components/unary/vent_scrubber,
		/obj/machinery/atmospherics/components/unary/vent_pump,
		/obj/machinery/navbeacon,
		/obj/machinery/power/terminal,
		/obj/machinery/power/apc,
		/obj/machinery/light_switch,
		/obj/machinery/light,
		/obj/machinery/camera,
		/obj/machinery/door/firedoor,
		/obj/machinery/firealarm,
		/obj/machinery/airalarm,
		/obj/structure/window/fulltile,
		/obj/structure/window/reinforced/fulltile,
	))
	/// Cached list of allowed typecaches for each type in what_you_can_see
	var/static/list/allowed_typecaches_by_root_type = null

/datum/dream/heretic/New(atom/dream_center)
	src.dream_center = dream_center

/datum/dream/heretic/Destroy(force)
	dream_center = null
	return ..()

/// Zwraca listę fragmentów snu (jak GenerateDream z tg)
/datum/dream/heretic/proc/GenerateDream(mob/living/carbon/dreamer)
	. = list()
	. += "wędrujesz przez las Mansusa"
	. += "jest tu " + pick("staw", "studnia", "jezioro", "kałuża", "strumień", "źródło", "potok", "mokradło")

	if(isnull(allowed_typecaches_by_root_type))
		allowed_typecaches_by_root_type = list()
		for(var/type in what_you_can_see)
			allowed_typecaches_by_root_type[type] = typecacheof(type) - what_you_cant_see

	var/list/all_objects = oview(dream_view_range, dream_center)
	var/something_found = FALSE
	for(var/object_type in allowed_typecaches_by_root_type)
		var/list/filtered_objects = typecache_filter_list(all_objects, allowed_typecaches_by_root_type[object_type])
		if(filtered_objects.len)
			if (!something_found)
				. += "w wodzie odbija się"
				something_found = TRUE
			var/obj/found_object = pick(filtered_objects)
			. += initial(found_object.name)
	if(!something_found)
		. += pick("jest zupełnie ciemno", "odbicia są niewyraźne", "błąkasz się bez celu")
	else
		. += "obrazy rozpływają się w zmarszczkach wody"
	. += "czujesz się wyczerpany"

/datum/mood_event/mansus_dream_fatigue
	description = "Muszę odpocząć, zanim znów przyśni mi się Mansus."
	mood_change = -2
	timeout = 5 MINUTES
