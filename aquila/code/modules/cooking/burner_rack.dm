/**
 * Zestaw palników maszyny: miejsca na patelnię, rondel albo garnek na zupę, każde z ogniem i minutnikiem.
 * Używa go kuchenka elektryczna i płyta grillowa. Maszyna woła procki zestawu ze swoich attackby, attack_hand,
 * Exited, process i examine.
 */
/datum/burner_rack
	var/obj/machinery/parent
	var/list/datum/cooking_surface/burner/burners = list()
	/// Położenie naczyń (x, y) na każdym palniku
	var/list/offsets
	/// Granica kliknięcia między przednimi a tylnymi palnikami (icon_y)
	var/row_split = 21

/datum/burner_rack/New(obj/machinery/parent, list/offsets, list/names, row_split = 21)
	. = ..()
	src.parent = parent
	src.offsets = offsets
	src.row_split = row_split
	for(var/i in 1 to length(offsets))
		var/datum/cooking_surface/burner/burner = new(parent)
		burner.name = names[i]
		burners += burner

/datum/burner_rack/Destroy(force)
	QDEL_LIST(burners)
	parent = null
	return ..()

/// Który palnik kliknięto (lewa/prawa połowa, przód/tył), albo pierwszy wolny
/datum/burner_rack/proc/burner_at(list/modifiers, free_only = FALSE)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(!isnull(icon_x) && !isnull(icon_y))
		var/index = (icon_x > 16 ? 2 : 1) + (icon_y > row_split ? 2 : 0)
		index = min(index, length(burners))
		var/datum/cooking_surface/burner/clicked = burners[index]
		if(!free_only || !clicked.container)
			return clicked
	if(free_only)
		for(var/datum/cooking_surface/burner/burner as anything in burners)
			if(!burner.container)
				return burner

/datum/burner_rack/proc/accepts(obj/item/thing)
	return burners[1].accepts(thing)

/// Naczynie na palnik albo składnik do naczynia na klikniętym palniku. Zwraca TRUE, jeśli zestaw to obsłużył.
/datum/burner_rack/proc/attackby(obj/item/used, mob/user, params)
	var/list/modifiers = params2list(params)
	var/datum/cooking_surface/burner/target = burner_at(modifiers)
	if(accepts(used))
		if(!(target && !target.container))
			target = burner_at(null, TRUE)
		if(!target)
			to_chat(user, span_warning("Wszystkie palniki są zajęte."))
			return TRUE
		place_container(used, target, user)
		return TRUE
	// Składnik użyty na maszynie trafia do naczynia na klikniętym palniku
	if(target?.container && !user.combat_mode && !(used.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH)) && !istype(used, /obj/item/storage/part_replacer))
		target.container.attackby(used, user, params)
		return TRUE
	return FALSE

/datum/burner_rack/proc/place_container(obj/item/pan, datum/cooking_surface/burner/burner, mob/user)
	if(user && !user.transferItemToLoc(pan, parent))
		return
	if(pan.loc != parent)
		pan.forceMove(parent)
	burner.set_container(pan)
	var/index = burners.Find(burner)
	pan.pixel_x = offsets[index][1]
	pan.pixel_y = offsets[index][2]
	pan.flags_1 |= IS_ONTOP_1
	pan.vis_flags |= VIS_INHERIT_PLANE
	var/obj/item/reagent_containers/cooking/cooking_pan = pan
	if(istype(cooking_pan))
		cooking_pan.make_mini()
		if(index % 2 == 0)
			pan.transform = matrix(-1, 0, 0, 0, 1, 0)
	else
		// Garnek na zupę jest duży, na palniku rysujemy go mniejszego
		pan.transform = matrix() * 0.6
	parent.vis_contents += pan
	if(user)
		to_chat(user, span_notice("Stawiasz [pan] na: [burner.name]."))
	parent.update_appearance()

/// Wołane z Exited maszyny: zdjęte naczynie zwalnia palnik i wraca do zwykłego wyglądu
/datum/burner_rack/proc/on_exited(atom/movable/gone)
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(burner.container != gone)
			continue
		burner.clear_container()
		var/obj/item/pan = gone
		parent.vis_contents -= pan
		pan.flags_1 &= ~IS_ONTOP_1
		pan.vis_flags &= ~VIS_INHERIT_PLANE
		pan.pixel_x = pan.base_pixel_x
		pan.pixel_y = pan.base_pixel_y
		pan.transform = null
		var/obj/item/reagent_containers/cooking/cooking_pan = pan
		if(istype(cooking_pan))
			cooking_pan.unmake_mini()
		parent.update_appearance()
		return TRUE
	return FALSE

/// Pusta ręka na palniku z naczyniem: zdejmuje naczynie. Zwraca TRUE, jeśli coś zdjęto.
/datum/burner_rack/proc/take(mob/user, list/modifiers)
	var/datum/cooking_surface/burner/burner = burner_at(modifiers)
	if(!burner?.container)
		return FALSE
	var/obj/item/pan = burner.container
	if(!user.put_in_hands(pan))
		pan.forceMove(parent.drop_location())
	return TRUE

/datum/burner_rack/proc/any_on()
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(burner.on)
			return TRUE
	return FALSE

/datum/burner_rack/proc/turn_all_off()
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		burner.turn_off()

/// Jeden tick włączonych palników. Zwraca liczbę włączonych.
/datum/burner_rack/proc/process_burners(delta_time, factor)
	. = 0
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(!burner.on)
			continue
		.++
		if(istype(burner.container, /obj/item/reagent_containers/glass/soup_pot))
			// Garnek z zupą: ogień ustala temperaturę zupy, jak na kuchence na zupy
			burner.tick_timer(delta_time)
			burner.container.reagents?.expose_temperature(burner.soup_target_temperature(), 0.033 * factor)
		else
			burner.process_cooking(delta_time, factor)

/datum/burner_rack/proc/examine_lines()
	. = list()
	for(var/datum/cooking_surface/burner as anything in burners)
		. += span_notice("[capitalize(burner.describe())].")
