// Kuchenka elektryczna z 4 palnikami. Sprite: Paradise (icons/obj/cooking/machines.dmi, stan "stove"), CC BY-SA 3.0.

/datum/cooking_surface/burner
	cooker_id = COOKER_STOVE
	allowed_containers = list(/obj/item/reagent_containers/cooking/pan, /obj/item/reagent_containers/cooking/pot)

/obj/machinery/cooking_stovetop
	name = "kuchenka elektryczna"
	desc = "Płyta z czterema palnikami do patelni i rondli. Każdy palnik ma własny ogień i minutnik."
	icon = 'aquila/icons/obj/food/cooking/machines.dmi'
	icon_state = "stove"
	density = FALSE
	pass_flags_self = PASSMACHINE | PASSTABLE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 30
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/cooking_stovetop
	var/list/datum/cooking_surface/burner/burners = list()
	/// Położenie naczyń na palnikach (x, y)
	var/static/list/burner_offsets = list(list(-7, 1), list(7, 1), list(-7, 12), list(7, 12))
	var/static/list/burner_names = list("lewy przedni palnik", "prawy przedni palnik", "lewy tylny palnik", "prawy tylny palnik")

/obj/machinery/cooking_stovetop/Initialize(mapload)
	for(var/i in 1 to 4)
		var/datum/cooking_surface/burner/burner = new(src)
		burner.name = burner_names[i]
		burners += burner
	kitchen_heat = new
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/cooking_stovetop/Destroy()
	QDEL_LIST(burners)
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/cooking_stovetop/get_cooking_surfaces()
	return burners

/obj/machinery/cooking_stovetop/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/cooking_stovetop/examine(mob/user)
	. = ..()
	. += span_notice("Kuchenka jest [kitchen_heat.describe()].")
	for(var/datum/cooking_surface/burner as anything in burners)
		. += span_notice("[capitalize(burner.describe())].")
	. += span_notice("Patelnię albo rondel stawiasz kliknięciem w wybrany palnik. <b>Alt+klik</b>: ustawienia palnika (włącz, ogień, minutnik).")

/// Który palnik kliknięto (po pozycji kursora), albo pierwszy wolny
/obj/machinery/cooking_stovetop/proc/burner_at(list/modifiers, free_only = FALSE)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(!isnull(icon_x) && !isnull(icon_y))
		var/index = (icon_x > 16 ? 2 : 1) + (icon_y > 21 ? 2 : 0)
		var/datum/cooking_surface/burner/clicked = burners[index]
		if(!free_only || !clicked.container)
			return clicked
	if(free_only)
		for(var/datum/cooking_surface/burner/burner as anything in burners)
			if(!burner.container)
				return burner

/obj/machinery/cooking_stovetop/attackby(obj/item/used, mob/user, params)
	var/list/modifiers = params2list(params)
	var/datum/cooking_surface/burner/target = burner_at(modifiers)
	if(target?.accepts(used) && !target.container)
		place_container(used, target, user)
		return TRUE
	if(burners[1].accepts(used))
		var/datum/cooking_surface/burner/free = burner_at(null, TRUE)
		if(!free)
			to_chat(user, span_warning("Wszystkie palniki są zajęte."))
			return TRUE
		place_container(used, free, user)
		return TRUE
	if(istype(used, /obj/item/reagent_containers/cooking))
		to_chat(user, span_warning("[used] nie pasuje na kuchenkę. Na palniki stawia się patelnię albo rondel."))
		return TRUE
	// Składnik użyty na kuchence trafia do naczynia na klikniętym palniku
	if(target?.container && !user.combat_mode && !(used.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH)) && !istype(used, /obj/item/storage/part_replacer))
		return target.container.attackby(used, user, params)
	return ..()

/obj/machinery/cooking_stovetop/proc/place_container(obj/item/reagent_containers/cooking/pan, datum/cooking_surface/burner/burner, mob/user)
	if(user && !user.transferItemToLoc(pan, src))
		return
	if(!user)
		pan.forceMove(src)
	burner.set_container(pan)
	var/index = burners.Find(burner)
	pan.pixel_x = burner_offsets[index][1]
	pan.pixel_y = burner_offsets[index][2]
	pan.flags_1 |= IS_ONTOP_1
	pan.vis_flags |= VIS_INHERIT_PLANE
	pan.make_mini()
	if(index == 2 || index == 4)
		pan.transform = matrix(-1, 0, 0, 0, 1, 0)
	vis_contents += pan
	if(user)
		to_chat(user, span_notice("Stawiasz [pan] na: [burner.name]."))
	update_appearance()

/obj/machinery/cooking_stovetop/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(burner.container != gone)
			continue
		burner.clear_container()
		var/obj/item/reagent_containers/cooking/pan = gone
		vis_contents -= pan
		pan.flags_1 &= ~IS_ONTOP_1
		pan.vis_flags &= ~VIS_INHERIT_PLANE
		pan.pixel_x = pan.base_pixel_x
		pan.pixel_y = pan.base_pixel_y
		pan.transform = null
		pan.unmake_mini()
		update_appearance()

/obj/machinery/cooking_stovetop/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/cooking_surface/burner/burner = burner_at(modifiers)
	if(burner?.container)
		var/obj/item/pan = burner.container
		if(!user.put_in_hands(pan))
			pan.forceMove(drop_location())
		return TRUE

/obj/machinery/cooking_stovetop/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	cooking_settings_menu(src, user)
	update_burner_processing()
	return TRUE

/obj/machinery/cooking_stovetop/proc/update_burner_processing()
	var/any_on = FALSE
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(burner.on)
			any_on = TRUE
			break
	kitchen_heat.set_heating(any_on)
	if(any_on)
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/cooking_stovetop/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		for(var/datum/cooking_surface/burner/burner as anything in burners)
			burner.turn_off()
		update_burner_processing()
		return
	var/active = 0
	var/factor = kitchen_heat_factor()
	for(var/datum/cooking_surface/burner/burner as anything in burners)
		if(!burner.on)
			continue
		active++
		burner.process_cooking(delta_time, factor)
	if(!active)
		update_burner_processing()
		return
	use_power(active_power_usage * active / max(kitchen_heat.rating, 1) * 2)

/obj/machinery/cooking_stovetop/update_overlays()
	. = ..()
	var/any_on = FALSE
	for(var/i in 1 to length(burners))
		var/datum/cooking_surface/burner/burner = burners[i]
		if(!burner.on)
			continue
		any_on = TRUE
		. += mutable_appearance(icon, "burner_[i]")
		. += emissive_appearance(icon, "burner_[i]", alpha = src.alpha)
		if(burner.container)
			. += mutable_appearance(icon, "steam_[i]", ABOVE_OBJ_LAYER)
	if(any_on)
		. += mutable_appearance(icon, "indicator")
	if(panel_open)
		. += mutable_appearance(icon, "stove_openpanel")

/obj/machinery/cooking_stovetop/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	update_appearance()

/obj/machinery/cooking_stovetop/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_crowbar(tool)

/obj/machinery/cooking_stovetop/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool, 2 SECONDS)

/// Z patelnią i rondlem na palnikach (do map)
/obj/machinery/cooking_stovetop/loaded/Initialize(mapload)
	. = ..()
	place_container(new /obj/item/reagent_containers/cooking/pan(src), burners[1])
	place_container(new /obj/item/reagent_containers/cooking/pot(src), burners[3])

/obj/item/circuitboard/machine/cooking_stovetop
	name = "kuchenka elektryczna (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/cooking_stovetop
	req_components = list(/obj/item/stock_parts/micro_laser = 2, /obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/datum/design/board/cooking_stovetop
	name = "Projekt maszyny (kuchenka elektryczna)"
	desc = "Płytka drukowana: kuchenka elektryczna z czterema palnikami."
	id = "cooking_stovetop"
	build_path = /obj/item/circuitboard/machine/cooking_stovetop
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
