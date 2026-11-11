// AQUILA - prom zbudowany Wyznacznikiem Stref Promu (budowa własnych promów z Bee) lata po overmapie NSV, na
// mechanice z shuttle_craft.dm. Sterownik lotu promu w środku przy pierwszym użyciu tworzy jednostkę overmapy,
// pyta o start, a potem steruje nią jak ster promu desantowego. Paliwo to plazma w podgrzewaczach silników
// (tak jak w supercruise), ciąg zależy od silników i masy promu. Wraca się na miejsce budowy albo na wolne miejsce
// przy kadłubie celu (wyjście przez śluzy promu).

/obj/structure/overmap/small_craft/transport/custom_shuttle
	name = "prom"
	desc = "Prom zbudowany Wyznacznikiem Stref Promu. Lata o własnych silnikach, a paliwo bierze z ich podgrzewaczy."
	icon = 'aquila/icons/overmap/custom_shuttle.dmi'
	icon_state = "shuttle"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 10, "overmap_medium" = 5, "overmap_heavy" = 50)
	sprite_size = 32
	damage_states = FALSE
	max_integrity = 300
	pixel_w = -16
	pixel_z = -20
	flight_pixel_w = -30
	flight_pixel_z = -32
	bound_width = 64
	bound_height = 64
	resize_factor = 1
	req_one_access = list()
	forward_maxthrust = 4
	backward_maxthrust = 4
	side_maxthrust = 4
	max_angular_acceleration = 80
	speed_limit = 5
	loadout_type = LOADOUT_UTILITY_ONLY
	interior_mode = NO_INTERIOR
	possible_interior_maps = list()
	components = list(/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery)
	/// Sterownik lotu w promie; silniki i paliwo liczy on
	var/obj/machinery/computer/shuttle_flight/custom_shuttle/flight_console
	/// Najwięcej paliwa, jakie prom miał (do wskaźnika paliwa)
	var/fuel_peak = 0

/obj/structure/overmap/small_craft/transport/custom_shuttle/Destroy()
	if(flight_console?.overmap_craft == src)
		flight_console.overmap_craft = null
	flight_console = null
	return ..()

/obj/structure/overmap/small_craft/transport/custom_shuttle/shuttle_anchor_turf()
	return get_turf(flight_console) || ..()

/obj/structure/overmap/small_craft/transport/custom_shuttle/get_fuel()
	. = flight_console ? flight_console.get_fuel() : 0
	fuel_peak = max(fuel_peak, .)

/obj/structure/overmap/small_craft/transport/custom_shuttle/get_max_fuel()
	return max(fuel_peak, get_fuel(), 1)

/obj/structure/overmap/small_craft/transport/custom_shuttle/set_fuel(amount)
	return FALSE

/// Silniki z paliwem w podgrzewaczach (silniki próżniowe paliwa nie potrzebują); liczy je consume_fuel()
/obj/structure/overmap/small_craft/transport/custom_shuttle/engines_active()
	return flight_console && flight_console.calculated_engine_count > 0

/// Silniki spalają plazmę z podgrzewaczy: przy ciągu więcej, na jałowym biegu mało
/obj/structure/overmap/small_craft/transport/custom_shuttle/use_fuel(force = FALSE)
	if(!flight_console || (!engines_active() && !force))
		return FALSE
	flight_console.consume_fuel(user_thrust_dir ? 0.25 : 0.05)
	if(engines_active())
		return TRUE
	set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/small_craft/transport/custom_shuttle/shuttle_can_launch(mob/user)
	if(!flight_console?.calculateStats())
		to_chat(user, span_warning("Sterownik nie widzi promu."))
		return FALSE
	if(flight_console.calculated_acceleration < CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT)
		to_chat(user, span_warning("Za mała moc silników, by wystartować. Dobuduj silniki albo odchudź prom."))
		return FALSE
	flight_console.consume_fuel(0.01)
	if(!engines_active())
		to_chat(user, span_warning("Silniki promu nie mają paliwa: napełnij ich podgrzewacze plazmą."))
		return FALSE
	// Mocniejsze silniki względem masy promu = żwawszy prom, w granicach promu pomocniczego
	var/thrust = clamp(round(flight_console.calculated_acceleration), 1, 6)
	forward_maxthrust = thrust
	backward_maxthrust = thrust
	side_maxthrust = thrust
	speed_limit = clamp(thrust + 1, 3, 6)
	return TRUE

/obj/structure/overmap/small_craft/transport/custom_shuttle/examine(mob/user)
	. = ..()
	. += span_notice("Paliwo w podgrzewaczach: [round(get_fuel(), 0.1)] mol. Stan kadłuba: [round(obj_integrity / max_integrity * 100)]%.")

// Sterownik lotu: w promie z jednostką overmapy steruje nią, bez niej działa po staremu

/obj/machinery/computer/shuttle_flight/custom_shuttle
	/// Jednostka overmapy tego promu
	var/obj/structure/overmap/small_craft/transport/custom_shuttle/overmap_craft

/obj/machinery/computer/shuttle_flight/custom_shuttle/Destroy()
	if(overmap_craft?.flight_console == src)
		overmap_craft.flight_console = null
	overmap_craft = null
	return ..()

/// Jednostka overmapy promu, w którym stoi sterownik; powstaje przy pierwszym użyciu, kiedy prom stoi w doku
/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/get_overmap_craft()
	if(!QDELETED(overmap_craft))
		return overmap_craft
	var/obj/docking_port/mobile/port = SSshuttle.getShuttle(shuttleId)
	if(!port?.docked || istype(port.docked, /obj/docking_port/stationary/transit) || !port.shuttle_areas[get_area(src)])
		return
	overmap_craft = new(get_turf(src))
	overmap_craft.flight_console = src
	overmap_craft.name = port.name
	overmap_craft.shuttle_link(port)
	// Plac budowy zostaje portem domowym promu (Wyznacznik ustawia mu usunięcie po pierwszym odlocie)
	if(overmap_craft.shuttle_home_port)
		overmap_craft.shuttle_home_port.delete_after = FALSE
	return overmap_craft

/obj/machinery/computer/shuttle_flight/custom_shuttle/get_overmap(failsafe = FALSE)
	if(!QDELETED(overmap_craft))
		return overmap_craft
	return ..()

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_interact(mob/user, datum/tgui/ui)
	var/obj/structure/overmap/small_craft/transport/custom_shuttle/craft = get_overmap_craft()
	if(!craft)
		return ..()
	if(!isliving(user))
		return
	if(craft.shuttle_docked_at && !SStgui.get_open_ui(user, src))
		if(tgui_alert(user, "[craft] stoi w doku. Startujemy?", name, list("Start", "Anuluj")) != "Start")
			return
		if(QDELETED(craft) || !craft.shuttle_docked_at || !user.Adjacent(src) || !craft.shuttle_launch(user))
			return
	craft.start_piloting(user, OVERMAP_USER_ROLE_PILOT)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls", "Sterowanie promem")
		ui.open()
		ui.set_autoupdate(TRUE) // Fuel gauge, ammo, etc

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_static_data(mob/user)
	if(!QDELETED(overmap_craft))
		return list()
	return ..()

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_data(mob/user)
	if(!QDELETED(overmap_craft))
		return overmap_craft.ui_data(user)
	return ..()

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_act(action, params, datum/tgui/ui)
	if(QDELETED(overmap_craft))
		return ..()
	if(action == "kick")
		return
	overmap_craft.ui_act(action, params, ui)
	return TRUE

// Zestaw budowy promu: na start rundy w inżynierii każdej mapy (wszystko poza materiałami i częściami maszyn)

/obj/item/storage/toolbox/shuttle_kit
	name = "zestaw budowy promu"
	desc = "Skrzynka z Wyznacznikiem Stref Promu oraz płytkami sterownika lotu, silników plazmowych i ich podgrzewaczy. Wystarczy dobudować ramy maszyn, a prom poleci na overmapę."
	icon_state = "blue"
	item_state = "toolbox_blue"
	material_flags = MATERIAL_NO_COLOR

/obj/item/storage/toolbox/shuttle_kit/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 20
	STR.max_items = 7

/obj/item/storage/toolbox/shuttle_kit/PopulateContents()
	new /obj/item/shuttle_creator(src)
	new /obj/item/circuitboard/computer/shuttle/flight_control(src)
	for(var/i in 1 to 2)
		new /obj/item/circuitboard/machine/shuttle/engine/plasma(src)
		new /obj/item/circuitboard/machine/shuttle/heater(src)
