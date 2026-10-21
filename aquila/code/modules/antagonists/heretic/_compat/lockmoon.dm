// AQUILA - zgodność dla ścieżek Lock i Moon (port heretyka z tg).
// Halucynacje ciał i puls halucynacji z tg, nastroje, dźwięk parady, osiągnięcia wzniesienia.
// cause_hallucination() i urojenia preset są we wspólnym _compat/shared.dm.

// --- Halucynacje ---

/// Biotypy, które nie halucynują (u nas mob_biotypes to lista)
#define LOCKMOON_NO_HALLUCINATION(living) ((MOB_ROBOTIC in living.mob_biotypes) || (MOB_SPIRIT in living.mob_biotypes))
/// Czas z tg (dziesiąte sekundy) na nasze tyknięcia Life() (~2 s)
#define LOCKMOON_TIME_TO_LIFE_TICKS(time) (CEILING((time) / 20, 1))

/datum/hallucination
	/// tg: waga w losowej puli (0 = nigdy losowo)
	var/random_hallucination_weight = 0
	/// tg: najbliższy abstrakcyjny rodzic
	var/abstract_hallucination_parent = /datum/hallucination

/// tg: losowy podtyp halucynacji z niezerową wagą
/proc/get_random_valid_hallucination_subtype(passed_type = /datum/hallucination)
	if(!ispath(passed_type, /datum/hallucination))
		CRASH("get_random_valid_hallucination_subtype - get_random_valid_hallucination_subtype passed not a hallucination subtype.")

	for(var/datum/hallucination/hallucination_type as anything in shuffle(subtypesof(passed_type)))
		if(initial(hallucination_type.abstract_hallucination_parent) == hallucination_type)
			continue
		if(initial(hallucination_type.random_hallucination_weight) <= 0)
			continue
		return hallucination_type

	return null

/**
 * tg: puls halucynacji wokół punktu - dotyka widzących środek, poza odpornymi na szaleństwo i ślepymi.
 * U nas halucynacje (zmienna hallucination) działają tylko na carbonach.
 */
/proc/visible_hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/carbon/nearby_living in view(radius, center))
		if(HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE) || HAS_MIND_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE))
			continue
		if(LOCKMOON_NO_HALLUCINATION(nearby_living))
			continue
		if(nearby_living.is_blind())
			continue
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		var/added = LOCKMOON_TIME_TO_LIFE_TICKS(hallucination_duration * dist)
		if(isnum(hallucination_max_duration))
			var/cap = LOCKMOON_TIME_TO_LIFE_TICKS(hallucination_max_duration)
			if(nearby_living.hallucination < cap)
				nearby_living.hallucination = min(nearby_living.hallucination + added, cap)
		else
			nearby_living.hallucination += added
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

// tg: krótko widoczne „ciało” w polu widzenia

// Na naszym systemie: całość dzieje się w New() (cause_hallucination ze wspólnego compat woła new typ(mob, TRUE))
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	/// Plik ikony ciała
	var/body_image_file
	/// Stan ikony ciała
	var/body_image_state
	/// Pokazany obraz
	var/image/shown_body
	/// Czy ciało unosi się w powietrzu
	var/body_floats = FALSE
	/// Warstwa obrazu
	var/body_layer = LOW_OBJ_LAYER

/datum/hallucination/body/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	if(!target?.client || target.stat >= UNCONSCIOUS)
		qdel(src)
		return

	var/list/possible_points = list()
	for(var/turf/open/open_turf in view(target))
		if(is_blocked_turf(open_turf))
			continue
		possible_points += open_turf

	if(!length(possible_points))
		qdel(src)
		return

	var/turf/picked = pick(possible_points)
	if(isspaceturf(picked) || !picked.has_gravity())
		body_floats = TRUE

	shown_body = make_body_image(picked)
	feedback_details += "Body: [body_image_state]"
	target.client?.images |= shown_body
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.

/datum/hallucination/body/Destroy()
	target?.client?.images -= shown_body
	shown_body = null
	return ..()

/// Tworzy obraz ciała w podanym miejscu
/datum/hallucination/body/proc/make_body_image(turf/location)
	var/image/created_image = image(body_image_file, location, body_image_state, body_layer)
	if(body_floats)
		animate(created_image, pixel_y = 2, time = 1 SECONDS, loop = -1)
		animate(pixel_y = -2, time = 1 SECONDS)
	return created_image

/datum/hallucination/body/husk
	random_hallucination_weight = 8
	body_image_file = 'icons/mob/human.dmi'
	body_image_state = "husk"

/datum/hallucination/body/husk/sideways
	random_hallucination_weight = 4

/datum/hallucination/body/husk/sideways/make_body_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

/datum/hallucination/body/ghost
	random_hallucination_weight = 2
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "ghost"
	body_floats = TRUE

/datum/hallucination/body/hole
	random_hallucination_weight = 1
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "blank"

/datum/hallucination/body/staticguy
	random_hallucination_weight = 1
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "static"

/datum/hallucination/body/weird
	random_hallucination_weight = 0.1
	abstract_hallucination_parent = /datum/hallucination/body/weird

/datum/hallucination/body/weird/alien
	body_image_file = 'icons/mob/alien.dmi'
	body_image_state = "alienother"
	body_floats = TRUE

/datum/hallucination/body/weird/mini_bubblegum
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "horror"

/datum/hallucination/body/weird/chrono
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "chronostuck"
	body_floats = TRUE

/datum/hallucination/body/weird/god
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "god"
	body_floats = TRUE

/datum/hallucination/body/weird/sling
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "shadowling_ascended"
	body_floats = TRUE

// --- Nastroje ---

/datum/mood_event/moon_smile
	description = "<span class='nicegreen'>KSIĘŻYC POKAZUJE MI PRAWDĘ, A JEGO UŚMIECH JEST ZWRÓCONY KU MNIE!!!</span>\n"
	mood_change = 10
	timeout = 2 MINUTES

/datum/mood_event/moon_insanity
	description = "<span class='boldwarning'>KSIĘŻYC MNIE OSĄDZA I UZNAJE ZA NIEGODNEGO!!!</span>\n"
	mood_change = -3
	timeout = 5 MINUTES

// --- Dźwięk parady ---

/datum/looping_sound/moon_parade
	mid_sounds = list('aquila/sound/effects/moon_parade_soundloop.ogg' = 1)
	mid_length = 2 SECONDS
	volume = 20

// --- Osiągnięcia wzniesienia ---

/datum/award/achievement/misc/lock_ascension
	name = "Secrets of the Locked Labyrinth"
	desc = "Udało ci się otworzyć bramę do Mansusa."
	database_id = "Lock Ascension"

/datum/award/achievement/misc/moon_ascension
	name = "The Last Act"
	desc = "Udało ci się zostać przewodnikiem parady i zabić kłamstwo."
	database_id = "Moon Ascension"

#undef LOCKMOON_NO_HALLUCINATION
#undef LOCKMOON_TIME_TO_LIFE_TICKS
