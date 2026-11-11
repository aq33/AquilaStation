/datum/hallucination/blood_flow
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The bleeding hallucination's image
	var/image/bleeding
	/// Ref to the bleeding bodypart, necessary to unregister signals
	var/obj/item/bodypart/bleeding_bodypart

/datum/hallucination/blood_flow/start()
	if(!hallucinator.client || !iscarbon(hallucinator))
		return FALSE

	var/mob/living/carbon/carb_hallucinator = hallucinator
	var/list/bodyparts = carb_hallucinator.bodyparts.Copy()
	if(!length(bodyparts) || HAS_TRAIT(carb_hallucinator, TRAIT_NO_BLOOD) || (NOBLOOD in carb_hallucinator.dna?.species?.species_traits))
		return FALSE

	var/obj/item/bodypart/picked = pick(bodyparts)

	bleeding_bodypart = picked

	feedback_details += "Bleeding: [bleeding_bodypart]"

	RegisterSignals(bleeding_bodypart, list(COMSIG_QDELETING, COMSIG_BODYPART_DROPPED), PROC_REF(stop_bleeding))

	to_chat(hallucinator, span_warning("Z twojej kończyny ([parse_zone(bleeding_bodypart.body_zone)]) tryska krew!"))
	var/bleed_duration = rand(16 SECONDS, 40 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(stop_bleeding)), bleed_duration)
	if(prob(25))
		addtimer(CALLBACK(src, PROC_REF(by_god)), bleed_duration * pick(0.5, 0.66))
	stamina_loop()

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/splat.ogg', 50, TRUE)
	bleeding = image(
		icon = 'aquila/icons/mob/effects/bleed_overlays.dmi',
		icon_state = "[bleeding_bodypart.body_zone]_[pick(2, 3)]",
		loc = hallucinator,
	)
	bleeding.color = COLOR_BLOOD
	bleeding.layer = -WOUND_LAYER
	hallucinator.client?.images += bleeding
	return TRUE

/datum/hallucination/blood_flow/Destroy()
	hallucinator.client?.images -= bleeding
	return ..()

/datum/hallucination/blood_flow/proc/by_god()
	if(QDELETED(src) || QDELETED(hallucinator) || QDELETED(bleeding_bodypart))
		return

	to_chat(hallucinator, span_warning("Krew nie przestaje płynąć, a jednak [parse_zone(bleeding_bodypart.body_zone)] wcale nie boli..."))

/datum/hallucination/blood_flow/proc/stop_bleeding()
	SIGNAL_HANDLER
	UnregisterSignal(bleeding_bodypart, list(COMSIG_QDELETING, COMSIG_BODYPART_DROPPED))
	if(!QDELETED(bleeding_bodypart))
		to_chat(hallucinator, span_warning("Krwawienie ([parse_zone(bleeding_bodypart.body_zone)]) ustaje."))
	if(!QDELETED(src))
		qdel(src)

/datum/hallucination/blood_flow/proc/stamina_loop()
	set waitfor = FALSE
	while(!QDELETED(src) && !QDELETED(hallucinator))
		hallucinator.adjust_stamina_loss(5)
		sleep(4 SECONDS)
