// AQUILA - konsola kontroli myśliwców (nsv13/code/modules/overmap/fighters/control_console.dm) i konsola katapult
// (nsv13/code/modules/overmap/fighters/fighters_launcher.dm) mają jedno okno „Lotnictwo” (AviationConsole.tsx)
// z zakładkami „Telemetria” i „Katapulty”. Obie konsole biorą dane z okrętu, nie od siebie nawzajem:
// - Telemetria: myśliwce frakcji konsoli (kontrola lotów: zmienna faction, konsola katapult: frakcja jej okrętu),
//   jak dotąd bez względu na poziom Z (stary filtr poziomów w kontroli lotów nigdy nic nie odsiewał).
// - Katapulty: konsola katapult jak dotąd katapulty ze swojego obszaru (get_launchers() przy otwarciu okna),
//   kontrola lotów wszystkie katapulty swojego okrętu (GLOB.aviation_fighter_launchers z tym samym linked).
// Akcje Telemetrii wymagają dostępu kontroli lotów (ACCESS_MAA albo emag) na obu konsolach; bez niego zakładka
// jest tylko do podglądu. Akcje Katapult nie wymagają dostępu, jak dotąd na konsoli katapult.
// Okno otwiera nazwa z hooka AQ EDIT w ui_interact obu plików core, akcje obu zakładek trafiają tu przez hook
// w ich ui_act (aviation_ui_act), a ui_data jest nadpisane w całości (LEGACY_OVERRIDES.md).

/// Wszystkie katapulty myśliwców w świecie (kontrola lotów wybiera z nich katapulty swojego okrętu)
GLOBAL_LIST_EMPTY(aviation_fighter_launchers)

/// aviation_act() zwraca to, gdy wysłała wiadomość do pilota (konsola ustawia wtedy przerwę między wiadomościami)
#define AVIATION_MESSAGE_SENT 2

/obj/structure/fighter_launcher/Initialize(mapload)
	. = ..()
	GLOB.aviation_fighter_launchers += src

/obj/structure/fighter_launcher/Destroy()
	GLOB.aviation_fighter_launchers -= src
	mag_locked = null
	linked = null
	return ..()

/obj/machinery/computer/ship/fighter_controller
	/// Kiedy wolno wysłać kolejną wiadomość do pilota z zakładki „Katapulty”
	var/next_message = 0

/obj/machinery/computer/ship/fighter_launcher
	/// Filtry zakładki „Telemetria”, jak w konsoli kontroli myśliwców (klucze to początkowe nazwy klas myśliwców)
	var/list/valid_filters = list("Only Occupied Ship", "Su-818 Rapier", "Su-410 Scimitar", "Su-437 Sabre")
	/// Widoczne klasy myśliwców; domyślnie wszystkie
	var/list/current_filters = null
	/// Frakcja myśliwców w zakładce „Telemetria”; null = frakcja okrętu konsoli
	var/faction = null

/obj/machinery/computer/ship/fighter_launcher/Initialize(mapload)
	. = ..()
	current_filters = valid_filters.Copy()

// --- wspólne dla obu konsol ---

/// Myśliwce danej frakcji widoczne w zakładce „Telemetria”
/obj/machinery/computer/ship/proc/aviation_fighters(fighter_faction)
	. = list()
	for(var/obj/structure/overmap/small_craft/OM in GLOB.overmap_objects) //Fighters may sit on a ship map, so only the global list has them all.
		if(QDELETED(OM) || OM.faction != fighter_faction)
			continue
		. += OM

/// Dane całego okna „Lotnictwo”; default_tab to zakładka otwierana na tej konsoli ("telemetry" albo "launchers")
/obj/machinery/computer/ship/proc/aviation_ui_data(mob/user, default_tab, fighter_faction, list/filters, list/all_filters, list/fighter_launchers, can_message)
	var/list/data = list()
	data["default_tab"] = default_tab
	data["ship_name"] = linked?.name
	data["can_control"] = aviation_telemetry_allowed(user)
	var/list/fighters = list()
	for(var/obj/structure/overmap/small_craft/OM as anything in aviation_fighters(fighter_faction))
		if(LAZYFIND(filters, "Only Occupied Ship") && !length(OM.operators))
			continue
		var/fighter_class = initial(OM.name)
		if(!LAZYFIND(filters, fighter_class))
			continue
		var/obj/item/fighter_component/docking_computer/DC = OM.loadout?.get_slot(HARDPOINT_SLOT_DOCKING)
		fighters += list(list(
			"id" = REF(OM),
			"name" = OM.name,
			"class" = fighter_class,
			"integrity" = OM.obj_integrity,
			"max_integrity" = OM.max_integrity,
			"safeties" = OM.weapon_safety,
			"has_docking" = !!DC,
			"docking_mode" = DC?.docking_mode,
		))
	data["fighters"] = fighters
	var/list/filter_types = list()
	for(var/fighter_class in all_filters)
		filter_types += list(list("class" = fighter_class, "visible" = LAZYFIND(filters, fighter_class) ? TRUE : FALSE))
	data["filter_types"] = filter_types
	var/list/launchers_info = list()
	for(var/obj/structure/fighter_launcher/FL in fighter_launchers)
		if(QDELETED(FL))
			continue
		var/obj/structure/overmap/small_craft/F = FL.mag_locked
		launchers_info += list(list(
			"id" = REF(FL),
			"name" = FL.name,
			"can_launch" = FL.ready,
			"mag_locked" = F?.name,
			"pilot" = F?.pilot ? F.pilot.name : null,
			"pilot_id" = F?.pilot ? REF(F.pilot) : null,
			"msg_cooldown" = can_message,
		))
	data["launchers_info"] = launchers_info
	return data

/// Czy user może wydawać polecenia z zakładki „Telemetria” (dostęp konsoli kontroli myśliwców albo emag)
/obj/machinery/computer/ship/proc/aviation_telemetry_allowed(mob/user)
	if(obj_flags & EMAGGED)
		return TRUE
	var/list/own_access = req_access
	req_access = list(ACCESS_MAA)
	. = allowed(user)
	req_access = own_access

/// Akcje obu zakładek poza filtrami. Zwraca TRUE, gdy akcja należy do okna (także gdy odmówiono),
/// AVIATION_MESSAGE_SENT po wysłaniu wiadomości do pilota.
/obj/machinery/computer/ship/proc/aviation_act(action, list/params, mob/user, fighter_faction, list/fighter_launchers, can_message)
	switch(action)
		if("launch", "release")
			var/obj/structure/fighter_launcher/FL = locate(params["id"])
			if(!istype(FL) || !(FL in fighter_launchers))
				return TRUE
			if(action == "launch")
				FL.start_launch()
			else
				FL.abort_launch()
			return TRUE
		if("message") //Lets you DM a pilot to tell them they're stupid or whatever.
			if(!can_message)
				return TRUE
			var/mob/living/pilot = locate(params["pilot_id"])
			if(!istype(pilot) || !aviation_pilot_on_launcher(pilot, fighter_launchers))
				return TRUE
			var/what = stripped_input(user, "Co chcesz przekazać [pilot]?")
			if(!what || QDELETED(pilot))
				return TRUE
			to_chat(pilot, "<span class='boldnotice'>Kontroler lotów: [what]</span>")
			return AVIATION_MESSAGE_SENT
		if("global_toggle", "global_eject", "eject", "toggle_safeties", "toggle_docking")
			if(!aviation_telemetry_allowed(user))
				to_chat(user, "<span class='warning'>Odmowa dostępu</span>")
				return TRUE
			aviation_fighter_act(action, params, user, fighter_faction)
			return TRUE
	return FALSE

/// Czy pilot siedzi w myśliwcu złapanym przez jedną z tych katapult (tylko do nich wolno pisać z zakładki „Katapulty”)
/obj/machinery/computer/ship/proc/aviation_pilot_on_launcher(mob/living/pilot, list/fighter_launchers)
	for(var/obj/structure/fighter_launcher/FL in fighter_launchers)
		if(FL.mag_locked?.pilot == pilot)
			return TRUE
	return FALSE

/// Polecenia zakładki „Telemetria” dla myśliwców danej frakcji
/obj/machinery/computer/ship/proc/aviation_fighter_act(action, list/params, mob/user, fighter_faction)
	if(action == "global_eject") //Messy. But oh boy do we fucking NEED IT
		if(alert(user, "Na pewno chcesz wyrzucić WSZYSTKICH PILOTÓW, KTÓRZY SĄ OBECNIE NA POKŁADZIE?", name, "Tak", "Nie") != "Tak" || !Adjacent(user))
			return
		message_admins("[key_name(user)] ([(user.mind && user.mind.antag_datums) ? "<b>Antagonista</b>" : "nie antagonista"]) wymusza katapultowanie wszystkich pilotów z myśliwców.")
	var/list/fighters = aviation_fighters(fighter_faction)
	if(action == "global_toggle" || action == "global_eject")
		for(var/obj/structure/overmap/small_craft/OM as anything in fighters)
			aviation_fighter_command(action == "global_toggle" ? "toggle_safeties" : "eject", OM, user)
		return
	var/obj/structure/overmap/small_craft/target = locate(params["id"])
	if(istype(target) && (target in fighters))
		aviation_fighter_command(action, target, user)

/obj/machinery/computer/ship/proc/aviation_fighter_command(action, obj/structure/overmap/small_craft/OM, mob/user)
	switch(action)
		if("eject")
			log_game("[key_name(user)] forcefully ejected people from [OM] from a [name] in [get_area(src)]!!")
			OM.force_eject()
		if("toggle_safeties")
			if(OM.pilot)
				to_chat(OM.pilot, "<span class='notice'>Operator zdalnie nadpisał ustawienia zabezpieczeń broni.</span>")
			OM.weapon_safety = !OM.weapon_safety
			log_game("[key_name(user)] forcefully [(OM.weapon_safety) ? "Enabled" : "Disabled"] [OM]'s weapon safeties from a [name] in [get_area(src)]!")
		if("toggle_docking")
			var/obj/item/fighter_component/docking_computer/DC = OM.loadout?.get_slot(HARDPOINT_SLOT_DOCKING)
			if(!DC)
				return
			if(OM.pilot)
				to_chat(OM.pilot, "<span class='notice'>Operator zdalnie nadpisał komputer dokowania.</span>")
			DC.docking_mode = !DC.docking_mode
			log_game("[key_name(user)] forcefully [(DC.docking_mode) ? "Enabled" : "Disabled"] [OM]'s docking computer from a [name] in [get_area(src)]!")

// --- konsola kontroli myśliwców: domyślnie Telemetria, katapulty całego okrętu ---

/// Katapulty okrętu tej konsoli
/obj/machinery/computer/ship/fighter_controller/proc/aviation_launchers()
	. = list()
	if(!linked && !has_overmap())
		return
	for(var/obj/structure/fighter_launcher/FL as anything in GLOB.aviation_fighter_launchers)
		if((FL.linked || FL.get_overmap()) == linked)
			. += FL

/obj/machinery/computer/ship/fighter_controller/ui_data(mob/user)
	return aviation_ui_data(user, "telemetry", faction, current_filters, valid_filters, aviation_launchers(), world.time >= next_message)

/obj/machinery/computer/ship/fighter_controller/aviation_telemetry_allowed(mob/user)
	return allowed(user) || (obj_flags & EMAGGED)

/// Hook z ui_act w core: TRUE, gdy akcja należy do okna „Lotnictwo” (core nie obsługuje jej już sam)
/obj/machinery/computer/ship/fighter_controller/proc/aviation_ui_act(action, list/params, mob/user)
	if(action == "filter")
		var/filter_name = params["filter"]
		if(!(filter_name in valid_filters))
			return TRUE
		if(LAZYFIND(current_filters, filter_name))
			LAZYREMOVE(current_filters, filter_name)
		else
			LAZYADD(current_filters, filter_name)
		return TRUE
	. = aviation_act(action, params, user, faction, aviation_launchers(), world.time >= next_message)
	if(. == AVIATION_MESSAGE_SENT)
		next_message = world.time + 5 SECONDS

// --- konsola katapult: domyślnie Katapulty, myśliwce frakcji okrętu ---

/obj/machinery/computer/ship/fighter_launcher/proc/aviation_faction()
	return faction || linked?.faction || "nanotrasen"

/obj/machinery/computer/ship/fighter_launcher/ui_data(mob/user)
	return aviation_ui_data(user, "launchers", aviation_faction(), current_filters, valid_filters, launchers, world.time >= next_message)

/// Hook z ui_act w core: TRUE, gdy akcja należy do okna „Lotnictwo” (core nie obsługuje jej już sam)
/obj/machinery/computer/ship/fighter_launcher/proc/aviation_ui_act(action, list/params, mob/user)
	if(action == "filter")
		var/filter_name = params["filter"]
		if(!(filter_name in valid_filters))
			return TRUE
		if(LAZYFIND(current_filters, filter_name))
			LAZYREMOVE(current_filters, filter_name)
		else
			LAZYADD(current_filters, filter_name)
		return TRUE
	. = aviation_act(action, params, user, aviation_faction(), launchers, world.time >= next_message)
	if(. == AVIATION_MESSAGE_SENT)
		next_message = world.time + 5 SECONDS

#undef AVIATION_MESSAGE_SENT

/// Kontrola lotów w stylu konsol goon (rzędy konsol na mostkach, np. Shrike, gdzie zastąpiła zbędny DRADIS)
/obj/machinery/computer/ship/fighter_controller/console
	icon = 'nsv13/goonstation/icons/obj/computer.dmi'
	icon_keyboard = null
	icon_screen = "shuttle"
