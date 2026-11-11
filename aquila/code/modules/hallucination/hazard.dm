/// Hallucinations that create a hazard somewhere nearby that actually has a danger associated.
/datum/hallucination/hazard
	abstract_hallucination_parent = /datum/hallucination/hazard
	random_hallucination_weight = 5
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// The type of effect we create
	var/hazard_type = /obj/effect/client_image_holder/hallucination/danger

/datum/hallucination/hazard/start()
	var/list/possible_points = list()
	for(var/turf/open/floor/floor_in_view in view(hallucinator))
		possible_points += floor_in_view

	if(!length(possible_points))
		return FALSE

	new hazard_type(pick(possible_points), hallucinator, src)
	QDEL_IN(src, rand(20 SECONDS, 45 SECONDS))
	return TRUE

/datum/hallucination/hazard/lava
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/lava

/datum/hallucination/hazard/chasm
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/chasm

/datum/hallucination/hazard/anomaly
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/anomaly

/// These hallucination effects cause side effects when the hallucinator walks into them.
/obj/effect/client_image_holder/hallucination/danger
	image_layer = TURF_LAYER

/obj/effect/client_image_holder/hallucination/danger/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(atom_touched_holder),
		COMSIG_ATOM_EXITED = PROC_REF(atom_touched_holder),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/client_image_holder/hallucination/danger/proc/atom_touched_holder(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!(entered in who_sees_us))
		return

	on_hallucinator_entered(entered)

/// Applies effects whenever the hallucinator enters the turf with our hallucination present.
/obj/effect/client_image_holder/hallucination/danger/proc/on_hallucinator_entered(mob/living/afflicted)
	return

/obj/effect/client_image_holder/hallucination/danger/lava
	name = "lawa"
	image_icon = 'icons/turf/floors/lava.dmi'
	image_state = "smooth"
	image_layer = TURF_LAYER

// AQUILA - u nas stary smoothing (narożniki), więc cały kafel jak w dawnej halucynacji

/obj/effect/client_image_holder/hallucination/danger/lava/on_hallucinator_entered(mob/living/afflicted)
	afflicted.adjustStaminaLoss(20)
	afflicted.cause_hallucination(/datum/hallucination/fire, "fake lava hallucination")

/obj/effect/client_image_holder/hallucination/danger/chasm
	name = "przepaść"
	image_icon = 'icons/turf/floors/chasms.dmi'
	image_state = "smooth"
	image_layer = TURF_LAYER


/obj/effect/client_image_holder/hallucination/danger/chasm/on_hallucinator_entered(mob/living/afflicted)
	to_chat(afflicted, span_userdanger("Wpadasz w przepaść!"))
	afflicted.visible_message(span_warning("[afflicted] nagle pada na ziemię!"), ignored_mobs = afflicted)
	afflicted.Paralyze(4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), afflicted, span_notice("...Zaskakująco tu płytko.")), 1.5 SECONDS)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/client_image_holder/hallucination/danger/anomaly
	name = "anomalia fali strumienia"
	image_icon = 'icons/effects/effects.dmi'
	image_state = "electricity2"
	image_layer = OBJ_LAYER + 0.01

/obj/effect/client_image_holder/hallucination/danger/anomaly/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/client_image_holder/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/client_image_holder/hallucination/danger/anomaly/process(delta_time)
	if(DT_PROB(45, delta_time))
		step(src, pick(GLOB.alldirs))

/obj/effect/client_image_holder/hallucination/danger/anomaly/on_hallucinator_entered(mob/living/afflicted)
	afflicted.cause_hallucination(/datum/hallucination/shock, "fake anomaly hallucination")
