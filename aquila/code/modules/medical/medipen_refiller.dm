// AQUILA - medipen refiller from tgstation (code/game/machinery/medipen_refiller.dm).
// Fill it with a beaker or through plumbing, then put an empty medipen in: 10 units of its main reagent refill the whole pen.
// Only our medipens whose main reagent can be made by chemists. Sprites from tgstation (CC-BY-SA 3.0).

/obj/machinery/medipen_refiller
	name = "automat do napełniania medipenów"
	desc = "Maszyna, która ponownie napełnia zużyte medipeny lekami."
	icon = 'aquila/icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/medipen_refiller
	/// Medipen type = the reagent it needs, the rest of the mix comes from the pen's own recipe
	var/static/list/allowed_pens = list(
		/obj/item/reagent_containers/hypospray/medipen = /datum/reagent/medicine/epinephrine,
		/obj/item/reagent_containers/hypospray/medipen/atropine = /datum/reagent/medicine/atropine,
		/obj/item/reagent_containers/hypospray/medipen/morphine = /datum/reagent/medicine/morphine,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = /datum/reagent/medicine/dexalin,
		/obj/item/reagent_containers/hypospray/medipen/survival = /datum/reagent/medicine/tricordrazine,
	)

/obj/machinery/medipen_refiller/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/medipen_refiller/RefreshParts()
	var/new_volume = 100
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		new_volume += 100 * bin.rating
	if(!reagents)
		create_reagents(new_volume, TRANSPARENT)
	reagents.maximum_volume = new_volume

/obj/machinery/medipen_refiller/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Napełnisz go zlewką albo przez rury. Pasujące medipeny: [english_list(get_pen_names())].</span>"
	if(reagents.total_volume)
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			. += "<span class='notice'>[round(reagent.volume, 0.01)] j. [reagent.name]</span>"

/obj/machinery/medipen_refiller/proc/get_pen_names()
	var/list/names = list()
	for(var/obj/item/pen_type as anything in allowed_pens)
		names += initial(pen_type.name)
	return names

/obj/machinery/medipen_refiller/attackby(obj/item/I, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(default_deconstruction_screwdriver(user, "medipen_refiller_open", "medipen_refiller", I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	if(src in user.do_afters)
		balloon_alert(user, "już tego używasz!")
		return TRUE
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen))
		refill_pen(I, user)
		return TRUE
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		if(!I.reagents.total_volume)
			balloon_alert(user, "nie ma czego przelać!")
			return TRUE
		var/obj/item/reagent_containers/container = I
		var/units = container.reagents.trans_to(src, container.amount_per_transfer_from_this, transfered_by = user)
		balloon_alert(user, units ? "przelano [units] j." : "zbiornik pełny!")
		return TRUE
	return ..()

/obj/machinery/medipen_refiller/proc/refill_pen(obj/item/reagent_containers/hypospray/medipen/medipen, mob/living/user)
	var/needed = allowed_pens[medipen.type]
	if(!needed)
		balloon_alert(user, "ten medipen nie pasuje!")
		return
	if(medipen.reagents.total_volume)
		balloon_alert(user, "medipen jest pełny!")
		return
	if(!reagents.has_reagent(needed, 10))
		balloon_alert(user, "za mało odczynników!")
		return
	add_overlay("active")
	if(do_after(user, 2 SECONDS, target = src) && !medipen.reagents.total_volume && reagents.has_reagent(needed, 10))
		medipen.reagents.maximum_volume = medipen.volume
		medipen.reagents.flags = medipen.reagent_flags
		medipen.add_initial_reagents()
		medipen.update_icon()
		reagents.remove_reagent(needed, 10)
		use_power(active_power_usage)
		balloon_alert(user, "napełniony")
	cut_overlay("active")

/obj/machinery/medipen_refiller/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("zajadle przepycha...")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	user.balloon_alert_to_viewers("przepchane")
	reagents.reaction(get_turf(src), TOUCH)
	reagents.clear_reagents()
	return TRUE

/obj/machinery/medipen_refiller/wrench_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE
	default_unfasten_wrench(user, I)
	return TRUE

/obj/item/circuitboard/machine/medipen_refiller
	name = "Medipen Refiller (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/medipen_refiller
	req_components = list(/obj/item/stock_parts/matter_bin = 1)

/datum/design/board/medipen_refiller
	name = "Machine Design (Medipen Refiller)"
	desc = "Płytka automatu, który ponownie napełnia zużyte medipeny."
	id = "medipen_refiller"
	build_path = /obj/item/circuitboard/machine/medipen_refiller
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
