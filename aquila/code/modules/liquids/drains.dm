// AQUILA - Ciecze: odpływy i bariera, port z Monkestation 2.0 (monkestation/code/modules/liquids/drains.dm, liquid_barrier.dm)

//Structure as this doesn't need any power to work
/obj/structure/drain
	name = "odpływ"
	icon = 'aquila/icons/obj/structures/drains.dmi'
	icon_state = "drain"
	desc = "Kratka odpływowa w podłodze, która chroni przed zalaniem."
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = FALSE
	plane = FLOOR_PLANE
	layer = GAS_SCRUBBER_LAYER
	anchored = TRUE
	var/processing = FALSE
	var/drain_flat = 5
	var/drain_percent = 0.1
	var/welded = FALSE
	var/turf/my_turf //need to keep track of it for the signal, if in any bizarre cases something would be moving the drain

/obj/structure/drain/update_icon_state()
	icon_state = welded ? "[initial(icon_state)]_welded" : "[initial(icon_state)]"
	return ..()

/obj/structure/drain/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[welded ? "Jest zaspawany, więc nic nie spływa." : "Można go zaspawać <b>spawarką</b>."]</span>"

/obj/structure/drain/welder_act(mob/living/user, obj/item/I)
	..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Zaczynasz [welded ? "rozspawywać" : "zaspawywać"] [src]...</span>")
	if(I.use_tool(src, user, 2 SECONDS))
		to_chat(user, "<span class='notice'>[welded ? "Rozspawujesz" : "Zaspawujesz"] [src].</span>")
		welded = !welded
		update_icon()
		if(welded)
			if(processing)
				STOP_PROCESSING(SSobj, src)
				processing = FALSE
		else if(!QDELETED(my_turf.liquids))
			START_PROCESSING(SSobj, src)
			processing = TRUE
	return TRUE

/obj/structure/drain/process(delta_time)
	if(QDELETED(my_turf.liquids) || QDELETED(my_turf.liquids.liquid_group))
		processing = FALSE
		return PROCESS_KILL
	var/datum/liquid_group/group = my_turf.liquids.liquid_group
	if(group.frozen) // lód nie spływa
		return
	var/drain_amt = drain_flat + (drain_percent * group.total_reagent_volume)
	group.remove_any(my_turf.liquids, min(round(drain_amt * delta_time, CHEMICAL_VOLUME_ROUNDING), group.total_reagent_volume))

/obj/structure/drain/Initialize(mapload)
	. = ..()
	if(!isturf(loc))
		stack_trace("Drain structure initialized not on a turf")
		return
	my_turf = loc
	RegisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION, PROC_REF(liquids_signal))
	if(my_turf.liquids)
		START_PROCESSING(SSobj, src)
		processing = TRUE

/obj/structure/drain/proc/liquids_signal()
	SIGNAL_HANDLER
	if(processing || welded)
		return
	START_PROCESSING(SSobj, src)
	processing = TRUE

/obj/structure/drain/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(my_turf)
		UnregisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION)
	my_turf = null
	return ..()

/obj/structure/drain/big
	name = "duży odpływ"
	desc = "Kratka odpływowa w podłodze, która chroni przed zalaniem. Ta jest wyjątkowo duża."
	icon_state = "bigdrain"
	drain_percent = 0.3
	drain_flat = 15

/obj/structure/liquid_barrier
	name = "bariera na ciecze"
	desc = "Skomplikowana siatka drenażowa w podłodze, która zatrzymuje wszystkie ciecze.\n<i>Ktoś musiał mieć bardzo dobry powód, żeby to zamontować...</i>"
	icon = 'aquila/icons/obj/structures/drains.dmi'
	icon_state = "bigdrain"
	plane = FLOOR_PLANE
	layer = GAS_SCRUBBER_LAYER
	density = FALSE
	anchored = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/turf/my_turf

/obj/structure/liquid_barrier/Initialize(mapload)
	. = ..()
	if(!isfloorturf(loc))
		if(mapload)
			log_mapping("[src] mapped onto a non-floor turf at [AREACOORD(src)]!")
		return
	my_turf = loc
	RegisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION, PROC_REF(on_liquid_creation))
	ADD_TRAIT(my_turf, TRAIT_BLOCK_LIQUID_SPREAD, REF(src))

/obj/structure/liquid_barrier/Destroy()
	if(my_turf)
		UnregisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION)
		REMOVE_TRAIT(my_turf, TRAIT_BLOCK_LIQUID_SPREAD, REF(src))
	my_turf = null
	return ..()

/obj/structure/liquid_barrier/proc/on_liquid_creation(datum/source)
	SIGNAL_HANDLER
	return BLOCK_LIQUID_CREATION

/// Zestaw odpływu z cargo: klucz na podłodze montuje odpływ
/obj/item/drain_kit
	name = "zestaw odpływu"
	desc = "Kratka odpływowa w kawałkach. Połóż na podłodze i przykręć kluczem."
	icon = 'aquila/icons/obj/structures/drains.dmi'
	icon_state = "drain"
	w_class = WEIGHT_CLASS_NORMAL
	/// Jaki odpływ powstanie (duży wymontowany zostaje duży)
	var/obj/structure/drain/drain_type = /obj/structure/drain

/obj/item/drain_kit/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!isfloorturf(T) || !isturf(loc))
		to_chat(user, "<span class='warning'>Najpierw połóż [src] na podłodze.</span>")
		return
	if(locate(/obj/structure/drain) in T)
		to_chat(user, "<span class='warning'>Tu już jest odpływ.</span>")
		return
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return
	new drain_type(T)
	to_chat(user, "<span class='notice'>Montujesz odpływ w podłodze.</span>")
	qdel(src)

/obj/structure/drain/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return
	to_chat(user, "<span class='notice'>Wymontowujesz [src].</span>")
	var/obj/item/drain_kit/kit = new(get_turf(src))
	kit.drain_type = type
	kit.icon_state = initial(icon_state)
	qdel(src)
