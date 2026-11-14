/// AQUILA - okno „Lotnictwo” (aquila/code/modules/overmap/consoles/aviation_console.dm): konsola kontroli myśliwców
/// i konsola katapult dają w ui_data dane obu zakładek, akcja z drugiej zakładki trafia do właściwego obiektu,
/// a polecenia Telemetrii z konsoli katapult wymagają dostępu kontroli lotów.
/datum/unit_test/aquila_aviation_console

/datum/unit_test/aquila_aviation_console/Run()
	var/obj/structure/overmap/small_craft/combat/light/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.faction = "nanotrasen"
	var/obj/machinery/computer/ship/fighter_controller/controller = allocate(/obj/machinery/computer/ship/fighter_controller)
	var/obj/machinery/computer/ship/fighter_launcher/launcher_console = allocate(/obj/machinery/computer/ship/fighter_launcher)
	var/obj/structure/fighter_launcher/launcher = allocate(/obj/structure/fighter_launcher)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	// okręt testowy: myśliwiec jest zarazem okrętem obu konsol i katapulty
	controller.linked = ship
	launcher_console.linked = ship
	launcher.linked = ship
	// domyślnie obie konsole pokazują tylko myśliwce z pilotem, a myśliwiec testowy jest pusty
	controller.current_filters -= "Only Occupied Ship"
	launcher_console.current_filters -= "Only Occupied Ship"
	launcher_console.get_launchers()
	if(!(launcher in launcher_console.launchers))
		return Fail("Konsola katapult nie widzi katapulty w swoim obszarze")

	var/ship_ref = REF(ship)
	var/launcher_ref = REF(launcher)
	for(var/obj/machinery/computer/ship/console as anything in list(controller, launcher_console))
		var/list/data = console.ui_data(user)
		var/found_fighter = FALSE
		for(var/list/fighter as anything in data["fighters"])
			if(fighter["id"] == ship_ref)
				found_fighter = TRUE
		if(!found_fighter)
			return Fail("[console.type] nie pokazuje myśliwca okrętu w zakładce Telemetria")
		var/found_launcher = FALSE
		for(var/list/launcher_info as anything in data["launchers_info"])
			if(launcher_info["id"] == launcher_ref)
				found_launcher = TRUE
		if(!found_launcher)
			return Fail("[console.type] nie pokazuje katapulty okrętu w zakładce Katapulty")
		if(!length(data["filter_types"]))
			return Fail("[console.type] nie ma filtrów Telemetrii")
	if(controller.ui_data(user)["default_tab"] != "telemetry" || launcher_console.ui_data(user)["default_tab"] != "launchers")
		return Fail("Zła domyślna zakładka konsol")

	// kontrola lotów zwalnia myśliwiec z katapulty (akcja zakładki Katapulty)
	launcher.mag_locked = ship
	ship.mag_lock = launcher
	controller.aviation_ui_act("release", list("id" = launcher_ref), user)
	if(launcher.mag_locked || ship.mag_lock)
		return Fail("Kontrola lotów nie zwolniła myśliwca z katapulty")

	// konsola katapult: polecenie Telemetrii bez dostępu jest odrzucone, z dostępem trafia w myśliwiec
	var/safety = ship.weapon_safety
	launcher_console.aviation_ui_act("toggle_safeties", list("id" = ship_ref), user)
	if(ship.weapon_safety != safety)
		return Fail("Konsola katapult przełączyła bezpieczniki bez dostępu kontroli lotów")
	if(launcher_console.ui_data(user)["can_control"])
		return Fail("Konsola katapult daje sterowanie Telemetrią bez dostępu")
	launcher_console.obj_flags |= EMAGGED
	launcher_console.aviation_ui_act("toggle_safeties", list("id" = ship_ref), user)
	if(ship.weapon_safety == safety)
		return Fail("Konsola katapult z dostępem nie przełączyła bezpieczników myśliwca")

	// filtr ukrywa klasę myśliwca na tej konsoli
	launcher_console.aviation_ui_act("filter", list("filter" = initial(ship.name)), user)
	for(var/list/fighter as anything in launcher_console.ui_data(user)["fighters"])
		if(fighter["id"] == ship_ref)
			return Fail("Filtr klasy nie ukrył myśliwca")
