// AQUILA - oczy w ciemności z tgstation/tgstation#89865 (z poprawką #92668), przerobione na nasz silnik:
// obraz tylko dla halucynującego przez client_image_holder, nasze świecące oczy z human_face.dmi,
// noktowizja sprawdzana przez lighting_alpha zamiast lighting_cutoff.

/// Próg jasności pola, poniżej którego oczy mogą się pojawić
#define EYES_IN_DARK_MAX_LUM 0.2

/datum/hallucination/eyes_in_dark
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The floating eye effect, somewhere in the world
	var/obj/effect/client_image_holder/hallucination/floating_eyes/eyes

/datum/hallucination/eyes_in_dark/Destroy()
	if(QDELETED(eyes))
		eyes = null
	else
		QDEL_NULL(eyes)
	return ..()

/datum/hallucination/eyes_in_dark/start()
	if(!hallucinator.client || hallucinator.stat >= UNCONSCIOUS)
		return FALSE

	// Noktowizja albo mezony: w ciemności i tak widać
	if(hallucinator.lighting_alpha < LIGHTING_PLANE_ALPHA_VISIBLE)
		return FALSE

	var/list/valid = list()
	for(var/turf/open/nearby in view(hallucinator))
		if(get_dist(nearby, hallucinator) <= 1)
			continue
		if(nearby.get_lumcount() > EYES_IN_DARK_MAX_LUM)
			continue
		valid += nearby

	if(!length(valid))
		return FALSE

	if(prob(5))
		to_chat(hallucinator, span_warning("Masz wrażenie, że ktoś cię obserwuje..."))

	var/turf/selected = pick(valid)
	feedback_details += "Eye coords: [selected.x], [selected.y], [selected.z]"
	eyes = new(selected, hallucinator, src)
	addtimer(CALLBACK(src, PROC_REF(end_hallucination_gracefully)), rand(60 SECONDS, 180 SECONDS))
	return TRUE

/datum/hallucination/eyes_in_dark/proc/end_hallucination_gracefully()
	if(QDELETED(src))
		return
	if(eyes?.shown_image)
		animate(eyes.shown_image, alpha = 0, time = 1 SECONDS)
	QDEL_IN(src, 1.2 SECONDS)

/// Para czerwonych oczu widoczna tylko dla halucynującego; znika w świetle i z bliska
/obj/effect/client_image_holder/hallucination/floating_eyes
	image_icon = 'icons/mob/human_face.dmi'
	image_state = "eyes_glow_gs"
	image_color = COLOR_DARK_RED
	image_plane = ABOVE_LIGHTING_PLANE
	image_layer = ABOVE_ALL_MOB_LAYER
	/// Already fading out
	var/fading = FALSE

/obj/effect/client_image_holder/hallucination/floating_eyes/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/client_image_holder/hallucination/floating_eyes/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/client_image_holder/hallucination/floating_eyes/process(delta_time)
	if(fading)
		return
	var/turf/below_us = get_turf(src)
	var/mob/living/seer = length(who_sees_us) ? who_sees_us[1] : null
	if(!seer || below_us.get_lumcount() > EYES_IN_DARK_MAX_LUM || seer.lighting_alpha < LIGHTING_PLANE_ALPHA_VISIBLE || get_dist(seer, src) <= 1)
		fading = TRUE
		animate(shown_image, alpha = 0, time = 0.5 SECONDS)
		QDEL_IN(parent, 0.75 SECONDS)

#undef EYES_IN_DARK_MAX_LUM
