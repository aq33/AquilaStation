// Grill na blat z dwoma rusztami, na węgiel drzewny z desek. Na wzór Paradise (code/modules/cooking/machines/grill.dm).
// Sprite: Paradise (icons/obj/cooking/machines.dmi, stany "grill", "fire_1", "fire_2", "wood_load"), CC BY-SA 3.0.

/datum/cooking_surface/grill_surface
	name = "ruszt"
	cooker_id = COOKER_GRILL
	allow_temp_change = FALSE
	allowed_containers = list(/obj/item/reagent_containers/cooking/grill_grate)

/datum/cooking_surface/grill_surface/turn_on(mob/user)
	var/obj/machinery/cooking_grill/grill = parent
	if(istype(grill) && grill.stored_wood <= 0)
		if(user)
			to_chat(user, span_warning("W [grill] nie ma węgla. Wrzuć najpierw deski."))
		return
	return ..()

/obj/effect/grill_hopper
	icon = 'aquila/icons/obj/food/cooking/machines.dmi'
	icon_state = "blank"
	vis_flags = VIS_INHERIT_ID
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/cooking_grill
	name = "grill na blat"
	desc = "Głęboki ruszt nad węglem drzewnym, stawiany na blacie. Z boku ma otwór na deski, z których robi się węgiel. Dwa ruszty, każdy z własnym minutnikiem."
	icon = 'aquila/icons/obj/food/cooking/machines.dmi'
	icon_state = "grill"
	density = FALSE
	pass_flags_self = PASSMACHINE | PASSTABLE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 20
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/cooking_grill
	var/list/datum/cooking_surface/grill_surface/grates = list()
	/// Węgiel z desek (jedna deska = jedna jednostka)
	var/stored_wood = 0
	var/wood_maximum = 30
	var/wood_consumption_rate = 0.025
	var/obj/effect/grill_hopper/hopper_overlay
	var/static/list/grate_offsets = list(list(-7, 3), list(7, 3))
	var/static/list/grate_names = list("lewy ruszt", "prawy ruszt")

/obj/machinery/cooking_grill/Initialize(mapload)
	for(var/i in 1 to 2)
		var/datum/cooking_surface/grill_surface/grate = new(src)
		grate.name = grate_names[i]
		grates += grate
	kitchen_heat = new
	hopper_overlay = new
	. = ..()
	vis_contents += hopper_overlay
	refresh_kitchen_heat()

/obj/machinery/cooking_grill/Destroy()
	for(var/datum/cooking_surface/grill_surface/grate as anything in grates)
		grate.container?.forceMove(drop_location())
	QDEL_LIST(grates)
	QDEL_NULL(kitchen_heat)
	vis_contents -= hopper_overlay
	QDEL_NULL(hopper_overlay)
	return ..()

/obj/machinery/cooking_grill/get_cooking_surfaces()
	return grates

/obj/machinery/cooking_grill/RefreshParts()
	. = ..()
	refresh_kitchen_heat()
	var/laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating
	wood_consumption_rate = initial(wood_consumption_rate) / max(1, laser_rating / 2)
	var/bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		bin_rating += bin.rating
	wood_maximum = 15 * max(bin_rating, 1)

/obj/machinery/cooking_grill/examine(mob/user)
	. = ..()
	. += span_notice("Węgiel: [round(stored_wood, 0.01)]/[wood_maximum].")
	for(var/datum/cooking_surface/grate as anything in grates)
		. += span_notice("[capitalize(grate.describe())].")
	. += span_notice("Ruszt stawiasz kliknięciem w lewą albo prawą połowę. Deski wrzucasz, klikając nimi grill. <b>Alt+klik</b>: włącz, wyłącz, minutnik.")

/// Który ruszt kliknięto (lewa albo prawa połowa), albo pierwszy wolny
/obj/machinery/cooking_grill/proc/grate_at(list/modifiers, free_only = FALSE)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	if(!isnull(icon_x))
		var/datum/cooking_surface/grill_surface/clicked = grates[icon_x > 16 ? 2 : 1]
		if(!free_only || !clicked.container)
			return clicked
	if(free_only)
		for(var/datum/cooking_surface/grill_surface/grate as anything in grates)
			if(!grate.container)
				return grate

/obj/machinery/cooking_grill/attackby(obj/item/used, mob/user, params)
	if(istype(used, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/sheet/mineral/wood/stack = used
		var/used_sheets = min(stack.get_amount(), round(wood_maximum - stored_wood))
		if(used_sheets <= 0)
			to_chat(user, span_warning("Zasobnik [src] jest pełny."))
			return TRUE
		if(!stack.use(used_sheets))
			return TRUE
		stored_wood += used_sheets
		to_chat(user, span_notice("Wrzucasz do [src] desek: [used_sheets]."))
		flick("wood_load", hopper_overlay)
		return TRUE
	var/list/modifiers = params2list(params)
	var/datum/cooking_surface/grill_surface/target = grate_at(modifiers)
	if(target?.accepts(used) && !target.container)
		place_container(used, target, user)
		return TRUE
	if(grates[1].accepts(used))
		var/datum/cooking_surface/grill_surface/free = grate_at(null, TRUE)
		if(!free)
			to_chat(user, span_warning("Oba ruszty są zajęte."))
			return TRUE
		place_container(used, free, user)
		return TRUE
	if(istype(used, /obj/item/reagent_containers/cooking))
		to_chat(user, span_warning("[used] nie pasuje na grill. Kładzie się na nim ruszt."))
		return TRUE
	// Składnik użyty na grillu trafia na kliknięty ruszt
	if(target?.container && !user.combat_mode && !(used.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH)) && !istype(used, /obj/item/storage/part_replacer))
		return target.container.attackby(used, user, params)
	return ..()

/obj/machinery/cooking_grill/proc/place_container(obj/item/reagent_containers/cooking/grate_item, datum/cooking_surface/grill_surface/grate, mob/user)
	if(user && !user.transferItemToLoc(grate_item, src))
		return
	if(!user)
		grate_item.forceMove(src)
	grate.set_container(grate_item)
	var/index = grates.Find(grate)
	grate_item.pixel_x = grate_offsets[index][1]
	grate_item.pixel_y = grate_offsets[index][2]
	grate_item.flags_1 |= IS_ONTOP_1
	grate_item.vis_flags |= VIS_INHERIT_PLANE
	grate_item.make_mini()
	if(index == 2)
		grate_item.transform = matrix(-1, 0, 0, 0, 1, 0)
	vis_contents += grate_item
	if(user)
		to_chat(user, span_notice("Kładziesz [grate_item] na: [grate.name]."))
	update_appearance()

/obj/machinery/cooking_grill/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/datum/cooking_surface/grill_surface/grate as anything in grates)
		if(grate.container != gone)
			continue
		grate.clear_container()
		var/obj/item/reagent_containers/cooking/grate_item = gone
		vis_contents -= grate_item
		grate_item.flags_1 &= ~IS_ONTOP_1
		grate_item.vis_flags &= ~VIS_INHERIT_PLANE
		grate_item.pixel_x = grate_item.base_pixel_x
		grate_item.pixel_y = grate_item.base_pixel_y
		grate_item.transform = null
		grate_item.unmake_mini()
		update_appearance()

/obj/machinery/cooking_grill/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/cooking_surface/grill_surface/grate = grate_at(modifiers)
	if(!grate?.container)
		return
	var/obj/item/grate_item = grate.container
	// Gorący ruszt parzy dłoń bez rękawic
	var/mob/living/carbon/human/cook = user
	if(grate.on && istype(cook) && !cook.gloves)
		cook.adjustFireLoss(2)
		to_chat(cook, span_danger("Parzysz sobie dłoń, zdejmując [grate_item] z [src]."))
	if(!user.put_in_hands(grate_item))
		grate_item.forceMove(drop_location())
	return TRUE

/obj/machinery/cooking_grill/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	cooking_settings_menu(src, user)
	update_grill_processing()
	return TRUE

/obj/machinery/cooking_grill/is_kitchen_active()
	for(var/datum/cooking_surface/grate as anything in grates)
		if(grate.on)
			return TRUE
	return FALSE

/obj/machinery/cooking_grill/proc/update_grill_processing()
	update_kitchen_heating()
	if(is_kitchen_active())
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/cooking_grill/process(delta_time)
	if(machine_stat & BROKEN)
		for(var/datum/cooking_surface/grate as anything in grates)
			grate.turn_off()
		update_grill_processing()
		return
	var/factor = kitchen_heat_factor()
	for(var/datum/cooking_surface/grate as anything in grates)
		if(!grate.on)
			continue
		if(stored_wood <= 0)
			grate.turn_off()
			visible_message(span_warning("W [src] skończył się węgiel."))
			continue
		stored_wood = max(0, stored_wood - wood_consumption_rate * delta_time)
		grate.process_cooking(delta_time, factor)
	if(!is_kitchen_active())
		update_grill_processing()

/obj/machinery/cooking_grill/update_overlays()
	. = ..()
	for(var/i in 1 to length(grates))
		var/datum/cooking_surface/grate = grates[i]
		if(grate.on)
			. += mutable_appearance(icon, "fire_[i]")
			. += emissive_appearance(icon, "fire_[i]", alpha = src.alpha)
	if(panel_open)
		. += mutable_appearance(icon, "grill_openpanel")

/obj/machinery/cooking_grill/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	update_appearance()

/obj/machinery/cooking_grill/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_crowbar(tool)

/obj/machinery/cooking_grill/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool, 2 SECONDS)

/// Z dwoma rusztami i pełnym zasobnikiem (do map)
/obj/machinery/cooking_grill/loaded/Initialize(mapload)
	. = ..()
	for(var/datum/cooking_surface/grill_surface/grate as anything in grates)
		place_container(new /obj/item/reagent_containers/cooking/grill_grate(src), grate)
	stored_wood = wood_maximum

/obj/item/circuitboard/machine/cooking_grill
	name = "grill na blat (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/cooking_grill
	req_components = list(/obj/item/stock_parts/micro_laser = 2, /obj/item/stock_parts/matter_bin = 2)
	needs_anchored = FALSE

/datum/design/board/cooking_grill
	name = "Projekt maszyny (grill na blat)"
	desc = "Płytka drukowana: grill na węgiel drzewny z dwoma rusztami, na blat."
	id = "cooking_grill"
	build_path = /obj/item/circuitboard/machine/cooking_grill
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
