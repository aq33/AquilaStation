// Kuchenka elektryczna z 4 palnikami. Sprite: Paradise (icons/obj/cooking/machines.dmi, stan "stove"), CC BY-SA 3.0.

/datum/cooking_surface/burner
	cooker_id = COOKER_STOVE
	allowed_containers = list(/obj/item/reagent_containers/cooking/pan, /obj/item/reagent_containers/cooking/pot, /obj/item/reagent_containers/glass/soup_pot)

/obj/machinery/cooking_stovetop
	name = "kuchenka elektryczna"
	desc = "Płyta z czterema palnikami do patelni, rondli i garnków na zupę. Stawia się ją na blacie. Każdy palnik ma własny ogień i minutnik."
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
	var/datum/burner_rack/rack
	var/static/list/burner_offsets = list(list(-7, 1), list(7, 1), list(-7, 12), list(7, 12))
	var/static/list/burner_names = list("lewy przedni palnik", "prawy przedni palnik", "lewy tylny palnik", "prawy tylny palnik")

/obj/machinery/cooking_stovetop/Initialize(mapload)
	rack = new(src, burner_offsets, burner_names)
	kitchen_heat = new
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/cooking_stovetop/Destroy()
	QDEL_NULL(rack)
	QDEL_NULL(kitchen_heat)
	return ..()

/// Palniki (dla testów i map)
/obj/machinery/cooking_stovetop/proc/burners()
	return rack.burners

/obj/machinery/cooking_stovetop/get_cooking_surfaces()
	return rack.burners

/obj/machinery/cooking_stovetop/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/cooking_stovetop/examine(mob/user)
	. = ..()
	. += span_notice("Kuchenka jest [kitchen_heat.describe()].")
	. += rack.examine_lines()
	. += span_notice("Patelnię, rondel albo garnek na zupę stawiasz kliknięciem w wybrany palnik. <b>Alt+klik</b>: ustawienia palnika (włącz, ogień, minutnik).")

/obj/machinery/cooking_stovetop/attackby(obj/item/used, mob/user, params)
	if(rack.attackby(used, user, params))
		return TRUE
	if(istype(used, /obj/item/reagent_containers/cooking))
		to_chat(user, span_warning("[used] nie pasuje na kuchenkę. Na palniki stawia się patelnię, rondel albo garnek na zupę."))
		return TRUE
	return ..()

/obj/machinery/cooking_stovetop/proc/place_container(obj/item/pan, datum/cooking_surface/burner/burner, mob/user)
	rack.place_container(pan, burner, user)

/obj/machinery/cooking_stovetop/Exited(atom/movable/gone, direction)
	. = ..()
	rack?.on_exited(gone)

/obj/machinery/cooking_stovetop/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(rack.take(user, modifiers))
		return TRUE

/obj/machinery/cooking_stovetop/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	cooking_settings_menu(src, user)
	update_burner_processing()
	return TRUE

/obj/machinery/cooking_stovetop/is_kitchen_active()
	return rack.any_on()

/obj/machinery/cooking_stovetop/proc/update_burner_processing()
	update_kitchen_heating()
	if(rack.any_on())
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/cooking_stovetop/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		rack.turn_all_off()
		update_burner_processing()
		return
	var/active = rack.process_burners(delta_time, kitchen_heat_factor())
	if(!active)
		update_burner_processing()
		return
	use_power(active_power_usage * active / max(kitchen_heat.rating, 1) * 2)

/obj/machinery/cooking_stovetop/update_overlays()
	. = ..()
	if(!rack)
		return
	var/any_on = FALSE
	for(var/i in 1 to length(rack.burners))
		var/datum/cooking_surface/burner/burner = rack.burners[i]
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
	place_container(new /obj/item/reagent_containers/cooking/pan(src), rack.burners[1])
	place_container(new /obj/item/reagent_containers/cooking/pot(src), rack.burners[3])

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
