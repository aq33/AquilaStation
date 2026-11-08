/// Makes a random body appear and disappear quickly.
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The file to make the body image from.
	var/body_image_file
	/// The icon state to make the body image form.
	var/body_image_state
	/// The actual image we made and showed show.
	var/image/shown_body
	/// AQUILA - z tg: ciało unosi się w powietrzu
	var/body_floats = FALSE

/datum/hallucination/body/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client)
		return FALSE

	var/list/possible_points = list()
	for(var/turf/open/floor/open_floor in view(hallucinator))
		possible_points += open_floor

	if(!length(possible_points))
		return FALSE

	shown_body = make_body_image(pick(possible_points))

	hallucinator.client?.images |= shown_body
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/body/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/body/proc/make_body_image(turf/location)
	var/image/created_image = image(body_image_file, location, body_image_state, TURF_LAYER)
	if(body_floats)
		animate(created_image, pixel_y = 2, time = 1 SECONDS, loop = -1)
		animate(pixel_y = -2, time = 1 SECONDS)
	return created_image

/datum/hallucination/body/husk
	random_hallucination_weight = 4
	body_image_file = 'icons/mob/human.dmi'
	body_image_state = "husk"

/datum/hallucination/body/husk/sideways
	random_hallucination_weight = 2

/datum/hallucination/body/husk/sideways/make_body_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

/datum/hallucination/body/alien
	random_hallucination_weight = 1
	body_image_file = 'icons/mob/alien.dmi'
	body_image_state = "alienother"
	hallucination_tier = HALLUCINATION_TIER_RARE

// AQUILA - pozostałe „ciała” z tg (dawniej w nakładce heretyka), z naszymi ikonami; poziomy jak w tgstation/tgstation#89865

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
	hallucination_tier = HALLUCINATION_TIER_RARE

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
	hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL

/datum/hallucination/body/weird/god
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "god"
	body_floats = TRUE

/datum/hallucination/body/weird/sling
	body_image_file = 'icons/mob/mob.dmi'
	body_image_state = "shadowling_ascended"
	body_floats = TRUE
