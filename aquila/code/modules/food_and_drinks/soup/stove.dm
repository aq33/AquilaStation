// AQUILA - kuchenka, kuchnia z piekarnikiem, garnek i chochla z tgstation/tgstation#74205 (Melbert; sprite'y kuchenki
// i garnka Kryson, chochli Kinneb). Różnice: brak sygnałów zmian odczynników (dym aktualizuje proces kuchenki,
// garnek sam opróżnia się ze składników), podgląd zawartości garnka w examine, chochla to mały pojemnik na
// odczynniki (u nas łyżki nie nabierają płynów), przełączanie palników także Alt+klikiem.

/// Temperatura, w której zupa zaczyna się przypalać (tg SOUP_BURN_TEMP)
#define SOUP_BURN_TEMP 540
/// Jedna porcja zupy (tg SOUP_SERVING_SIZE)
#define SOUP_SERVING_SIZE 25
/// Wrzenie wody (tg WATER_BOILING_POINT)
#define SOUP_WATER_BOILING_POINT (T0C + 100)

/**
 * # Stove Component
 *
 * Makes the attached object a stove
 *
 * Pots can be put on the stove to make soup, and attack-handing it will start processing
 * where it will heat up the pot's reagents inside
 */
/datum/component/stove
	/// Whether we're currently cooking
	var/on = FALSE
	/// A reference to the current soup pot overtop
	var/obj/item/container
	/// A particle holder for the smoke that comes out of the soup while a container is cooking.
	var/obj/effect/abstract/particle_holder/soup_smoke
	/// Typepath of particles to use for the particle holder.
	var/particle_type = /particles/smoke/steam/mild
	/// The color of the flames around the burner.
	var/flame_color = "#006eff"
	/// Container's pixel x when placed on the stove
	var/container_x = 0
	/// Container's pixel y when placed on the stove
	var/container_y = 8
	/// Modifies how much temperature is exposed to the reagents, and in turn modifies how fast the reagents are heated.
	var/heat_coefficient = 0.033

/datum/component/stove/Initialize(container_x = 0, container_y = 8, obj/item/spawn_container)
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

	src.container_x = container_x
	src.container_y = container_y

	// To allow maploaded pots on top of your stove.
	if(spawn_container)
		spawn_container.forceMove(parent)
		add_container(spawn_container)

/datum/component/stove/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlay_update))
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_deconstructed))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/stove/UnregisterFromParent()
	if(!QDELING(parent) && container)
		var/obj/machinery/real_parent = parent
		container.forceMove(real_parent.drop_location())

	QDEL_NULL(soup_smoke)
	STOP_PROCESSING(SSobj, src)

	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_CLICK_ALT,
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_PARENT_EXAMINE,
	))

/datum/component/stove/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(soup_smoke)
	container = null
	return ..()

/datum/component/stove/process(delta_time)
	var/obj/machinery/real_parent = parent
	if(real_parent.machine_stat & NOPOWER)
		turn_off()
		return

	container?.reagents?.expose_temperature(SOUP_BURN_TEMP + 80, heat_coefficient)
	real_parent.use_power(real_parent.active_power_usage)
	update_smoke_type()

	var/turf/stove_spot = real_parent.loc
	if(isturf(stove_spot))
		stove_spot.hotspot_expose(SOUP_BURN_TEMP + 80, 100)

/datum/component/stove/proc/turn_on()
	var/obj/machinery/real_parent = parent
	if(real_parent.machine_stat & (BROKEN|NOPOWER))
		return
	START_PROCESSING(SSobj, src)
	on = TRUE
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/turn_off()
	var/obj/machinery/real_parent = parent
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	real_parent.update_appearance(UPDATE_OVERLAYS)

/// Włącza albo wyłącza palniki
/datum/component/stove/proc/toggle_burners(mob/user)
	var/obj/machinery/real_parent = parent
	if(on)
		turn_off()
	else if(real_parent.machine_stat & (BROKEN|NOPOWER))
		real_parent.balloon_alert(user, "brak zasilania!")
		return
	else
		turn_on()

	real_parent.balloon_alert(user, "palniki [on ? "włączone" : "wyłączone"]")
	playsound(real_parent, 'sound/machines/click.ogg', 30, TRUE)
	playsound(real_parent, on ? 'sound/items/welderactivate.ogg' : 'sound/items/welderdeactivate.ogg', 15, TRUE)

/datum/component/stove/proc/on_attack_hand_secondary(obj/machinery/source, mob/user)
	SIGNAL_HANDLER
	toggle_burners(user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/component/stove/proc/on_alt_click(obj/machinery/source, mob/user)
	SIGNAL_HANDLER
	if(!user.canUseTopic(source, BE_CLOSE))
		return
	toggle_burners(user)
	return COMPONENT_INTERCEPT_ALT

/datum/component/stove/proc/on_attackby(obj/machinery/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(!attacking_item.is_open_container() || !attacking_item.reagents)
		return
	if(istype(attacking_item, /obj/item/reagent_containers/glass/soup_ladle))
		if(container)
			INVOKE_ASYNC(attacking_item, TYPE_PROC_REF(/obj/item, afterattack), container, user, TRUE)
		return COMPONENT_NO_AFTERATTACK
	if(!isnull(container))
		to_chat(user, span_warning("Nie odważysz się gotować dwóch rzeczy naraz na jednej kuchence. A jeśli się pomieszają?"))
		return COMPONENT_NO_AFTERATTACK

	if(user.transferItemToLoc(attacking_item, parent))
		add_container(attacking_item, user)
		to_chat(user, span_notice("Stawiasz [attacking_item] na [parent]."))
	return COMPONENT_NO_AFTERATTACK

/datum/component/stove/proc/on_exited(obj/machinery/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == container)
		remove_container()

/datum/component/stove/proc/on_deconstructed(obj/machinery/source)
	SIGNAL_HANDLER

	container?.forceMove(source.drop_location())

/datum/component/stove/proc/on_overlay_update(obj/machinery/source, list/overlays)
	SIGNAL_HANDLER

	update_smoke()

	if(!on)
		return

	var/obj/real_parent = parent
	var/stove_icon = (istype(real_parent, /obj/machinery/oven/range)) ? 'aquila/icons/obj/food/soup/kitchen_range.dmi' : real_parent.icon
	var/stove_state = (istype(real_parent, /obj/machinery/oven/range)) ? "range" : "stove"

	// Flames around the pot
	var/mutable_appearance/flames = mutable_appearance(stove_icon, "[stove_state]_on_flame", alpha = real_parent.alpha)
	flames.color = flame_color
	overlays += flames
	overlays += emissive_appearance(stove_icon, "[stove_state]_on_flame", alpha = real_parent.alpha)

	// A green light that shows it's active
	var/mutable_appearance/light = mutable_appearance(stove_icon, "[stove_state]_on_overlay", alpha = real_parent.alpha)
	light.color = "#00ff00"
	overlays += light
	overlays += emissive_appearance(stove_icon, "[stove_state]_on_overlay", alpha = real_parent.alpha)

/datum/component/stove/proc/on_examine(obj/machinery/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Palniki [on ? "wyłączysz" : "włączysz"] [user.secondary_click_text()] albo Alt+klikiem.")
	if(container)
		examine_list += span_notice("Na palnikach stoi [container].")

/// Laser w płytce przyspiesza grzanie (tg: COMSIG_MACHINERY_REFRESH_PARTS)
/datum/component/stove/proc/refresh_heat(obj/machinery/source)
	var/new_multiplier = 0
	for(var/obj/item/stock_parts/micro_laser/part in source.component_parts)
		new_multiplier += (part.rating * 0.5)
	heat_coefficient = initial(heat_coefficient) * max(round(new_multiplier), 1)

/datum/component/stove/proc/add_container(obj/item/new_container, mob/user)
	var/obj/real_parent = parent
	real_parent.vis_contents += new_container
	new_container.flags_1 |= IS_ONTOP_1
	new_container.vis_flags |= VIS_INHERIT_PLANE

	container = new_container
	container.pixel_x = container_x
	container.pixel_y = container_y

	update_smoke_type()
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/remove_container()
	var/obj/real_parent = parent
	container.flags_1 &= ~IS_ONTOP_1
	container.vis_flags &= ~VIS_INHERIT_PLANE
	real_parent.vis_contents -= container

	container.pixel_x = container.base_pixel_x
	container.pixel_y = container.base_pixel_y
	container = null

	update_smoke_type()
	real_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/stove/proc/update_smoke_type()
	var/existing_temp = container?.reagents?.chem_temp || 0
	var/new_type
	if(existing_temp >= SOUP_BURN_TEMP)
		new_type = /particles/smoke/steam
	else if(existing_temp >= SOUP_WATER_BOILING_POINT)
		new_type = /particles/smoke/steam/mild
	if(new_type == particle_type && (soup_smoke || isnull(new_type)))
		return
	particle_type = new_type
	update_smoke()

/datum/component/stove/proc/update_smoke()
	if(on && container?.reagents?.total_volume > 0 && particle_type)
		if(isnull(soup_smoke) || soup_smoke.particles?.type != particle_type)
			QDEL_NULL(soup_smoke)
			soup_smoke = new(parent, particle_type)
			if(soup_smoke.particles)
				soup_smoke.particles.position = list(container_x, round(world.icon_size * 0.66), 0)
				// Płótno /particles/smoke ma 100 px wysokości (±50 od środka), a para leci wyżej i była ucinana
				soup_smoke.particles.height = 256
		return

	QDEL_NULL(soup_smoke)

/obj/machinery/stove
	name = "kuchenka"
	desc = "Można by pomyśleć, że coś takiego przyda się tu bardziej."
	icon = 'aquila/icons/obj/food/soup/kitchen_stove.dmi'
	icon_state = "stove"
	base_icon_state = "stove"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/stove
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 40

/obj/machinery/stove/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stove, container_x = -6, container_y = 16)

/obj/machinery/stove/RefreshParts()
	. = ..()
	var/datum/component/stove/stove = GetComponent(/datum/component/stove)
	stove?.refresh_heat(src)

/obj/machinery/stove/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_crowbar(tool, ignore_panel = TRUE)

/obj/machinery/stove/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool, 2 SECONDS)

/// Kuchnia: piekarnik z palnikami na wierzchu
/obj/machinery/oven/range
	name = "kuchnia"
	desc = "Piekarnik I kuchenka? Pewnie dlatego tyle w niej mocy!"
	icon = 'aquila/icons/obj/food/soup/kitchen_range.dmi'
	icon_state = "range_off"
	base_icon_state = "range"
	pass_flags_self = PASSMACHINE | PASSTABLE | LETPASSTHROW
	circuit = /obj/item/circuitboard/machine/range
	active_power_usage = 50

/obj/machinery/oven/range/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/soup_pot/mapload_container
	if(mapload)
		mapload_container = new(loc)
	AddComponent(/datum/component/stove, container_x = -6, container_y = 14, spawn_container = mapload_container)

/obj/machinery/oven/range/RefreshParts()
	. = ..()
	var/datum/component/stove/stove = GetComponent(/datum/component/stove)
	stove?.refresh_heat(src)

// Nasz piekarnik ma stany „oven_*” wpisane na sztywno, kuchnia rysuje swoje „range_*”
/obj/machinery/oven/range/update_icon_state()
	. = ..()
	icon_state = (!open && used_tray?.contents.len) ? "range_on" : "range_off"

/obj/machinery/oven/range/update_overlays()
	. = ..()
	if(open)
		var/mutable_appearance/door_overlay = mutable_appearance(icon, "range_lid_open")
		door_overlay.pixel_y = -15
		. += door_overlay
	else
		. += mutable_appearance(icon, "range_lid_closed")
		if(used_tray?.contents.len)
			. += emissive_appearance(icon, "range_light_mask", alpha = src.alpha)

/obj/item/circuitboard/machine/stove
	name = "kuchenka (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/stove
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
	needs_anchored = TRUE

/obj/item/circuitboard/machine/range
	name = "kuchnia z piekarnikiem (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/oven/range
	req_components = list(/obj/item/stock_parts/micro_laser = 2)
	needs_anchored = TRUE

/datum/design/board/stove
	name = "Projekt maszyny (kuchenka)"
	desc = "Płytka drukowana: kuchenka."
	id = "stove"
	build_path = /obj/item/circuitboard/machine/stove
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/board/range
	name = "Projekt maszyny (kuchnia z piekarnikiem)"
	desc = "Płytka drukowana: kuchnia, czyli piekarnik z palnikami."
	id = "range"
	build_path = /obj/item/circuitboard/machine/range
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/bio_process/New()
	. = ..()
	design_ids += list("stove", "range")
