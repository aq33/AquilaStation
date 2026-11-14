/**
 * AQUILA - konsola nawigacji i stary komputer FTL w jednym oknie „Nawigacja i skok” (Starmap.tsx).
 *
 * Okno ma zakładki: mapa gwiezdna, okręt, wybrany układ i napęd FTL. Dane mapy buduje starmap_ui_data() na
 * /obj/machinery/computer/ship, więc ten sam kod obsługuje konsolę nawigacji (stan w jej zmiennych z core:
 * screen, selected_system, current_sector) i komputer FTL (stan w zmiennych nav_* poniżej).
 * Zakładka „Napęd FTL” pokazuje napęd okrętu (linked.ftl_drive): stary komputer FTL da się z niej sterować
 * z tym samym dostępem co przy samej maszynie (req_access komputera FTL), napęd modułowy (rdzeń i pylony)
 * tylko podgląd, bo jego panel jest w maszynowni.
 * Komputer FTL na mapie otwiera to samo okno, od razu na zakładce napędu.
 */

#define NAV_SCREEN_SHIPINFO 0
#define NAV_SCREEN_STARMAP 1
#define NAV_SCREEN_SYSTEM 2
#define NAV_SCREEN_FTL 3

/obj/machinery/computer/ship/navigation
	/// Czy konsola korzysta ze scalonego okna z zakładką napędu (astrometria ma własne okno)
	var/merged_ftl_tab = TRUE

/obj/machinery/computer/ship/navigation/astrometrics
	merged_ftl_tab = FALSE

/obj/machinery/computer/ship/ftl_computer
	/// Zakładka scalonego okna nawigacji; komputer FTL zaczyna od napędu
	var/nav_screen = NAV_SCREEN_FTL
	/// Układ wybrany na mapie w oknie tego komputera
	var/datum/star_system/nav_selected_system
	/// Sektor pokazywany na mapie w oknie tego komputera
	var/nav_sector = SECTOR_NEUTRAL

// Reguły mapy: czy układ jest w zasięgu, odwiedzony i czy wolno do niego wrócić po końcu misji.
// Konsola nawigacji (i jej podtypy, np. astrometria) ma własne procki is_in_range() i is_visited().

/obj/machinery/computer/ship/proc/starmap_in_range(datum/star_system/current_system, datum/star_system/system)
	return LAZYFIND(current_system?.adjacency_list, system?.name)

/obj/machinery/computer/ship/proc/starmap_visited(datum/star_system/system)
	return system.visited

/obj/machinery/computer/ship/proc/starmap_return_jump(datum/star_system/system)
	return ((SSovermap_mode.already_ended || SSovermap_mode.round_extended) && istype(system, /datum/star_system/outpost))

/obj/machinery/computer/ship/navigation/starmap_in_range(datum/star_system/current_system, datum/star_system/system)
	return is_in_range(current_system, system)

/obj/machinery/computer/ship/navigation/starmap_visited(datum/star_system/system)
	return is_visited(system)

/obj/machinery/computer/ship/navigation/starmap_return_jump(datum/star_system/system)
	return return_jump_check(system)

/// Czy z tej konsoli wolno skakać i sterować napędem (publiczna mapa i astrometria tylko pokazują)
/obj/machinery/computer/ship/proc/starmap_can_control()
	return TRUE

/obj/machinery/computer/ship/navigation/starmap_can_control()
	return can_control_ship && merged_ftl_tab

/// Czy napęd okrętu pozwala teraz skoczyć do układu (to samo, co pokazuje przycisk „Skok”)
/obj/machinery/computer/ship/proc/starmap_can_jump(datum/star_system/target)
	if(!linked?.ftl_drive || !target || !starmap_can_control())
		return FALSE
	var/datum/star_system/current_system = SSstar_system.ships[linked]?["current_system"]
	if(!current_system)
		return FALSE
	var/obj/machinery/computer/ship/ftl_core/drive = linked.ftl_drive
	if(current_system.dist(target) < drive.max_range && drive.ftl_state == FTL_STATE_READY && LAZYFIND(current_system.adjacency_list, target.name))
		return TRUE
	if(linked.ftl_safety_override && drive.ftl_state != FTL_STATE_JUMPING)
		return TRUE
	if(starmap_return_jump(target) && drive.ftl_state == FTL_STATE_READY)
		return TRUE
	return FALSE

/**
 * Dane okna mapy gwiezdnej (przeniesione z /obj/machinery/computer/ship/navigation/ui_data w starmap.dm, te same klucze).
 * Dodatkowo zawsze: position (gdzie jest okręt, do paska stanu), selected_name i ftl (zakładka napędu).
 */
/obj/machinery/computer/ship/proc/starmap_ui_data(mob/user, screen, datum/star_system/selected_system, current_sector, can_control_ship)
	var/list/data = list()
	var/list/info = SSstar_system.ships[linked]
	var/list/lines = list()
	if(!info?.len)
		return data

	var/datum/star_system/current_system = info["current_system"]
	SSstar_system.update_pos(linked)
	if(linked.ftl_drive)
		if(istype(linked.ftl_drive))
			data["ftl_progress"] = linked.ftl_drive.progress
			data["ftl_goal"] = linked.ftl_drive.req_charge
		else if(istype(linked.ftl_drive, /obj/machinery/computer/ship/ftl_computer))
			var/obj/machinery/computer/ship/ftl_computer/legacy = linked.ftl_drive
			data["ftl_progress"] = legacy.progress
			data["ftl_goal"] = legacy.spoolup_time
	data["travelling"] = FALSE

	// Położenie okrętu do paska stanu, niezależnie od zakładki
	var/list/position = list()
	var/datum/star_system/target_system = info["target_system"]
	var/datum/star_system/last_system = info["last_system"]
	if(target_system && last_system)
		position["in_transit"] = TRUE
		position["from_name"] = last_system.name
		position["from_id"] = "\ref[last_system]"
		position["to_name"] = target_system.name
		position["to_id"] = "\ref[target_system]"
		position["time_left"] = max(0, (info["to_time"] - world.time) / 1 MINUTES)
	else
		position["in_transit"] = FALSE
		position["star_name"] = current_system?.name
		position["star_id"] = current_system ? "\ref[current_system]" : null
	data["position"] = position
	data["selected_name"] = selected_system?.name
	data["current_sector"] = current_sector

	switch(screen)
		if(NAV_SCREEN_SHIPINFO)
			if(!target_system)
				data["in_transit"] = FALSE
				data["star_id"] = "\ref[current_system]"
				data["star_name"] = current_system?.name
			else
				data["in_transit"] = TRUE
				data["from_star_id"] = "\ref[last_system]"
				data["from_star_name"] = last_system?.name
				data["to_star_id"] = "\ref[target_system]"
				data["to_star_name"] = target_system.name
				data["time_left"] = max(0, (info["to_time"] - world.time) / 1 MINUTES)

		if(NAV_SCREEN_STARMAP)
			var/list/systems_list = list()
			if(current_system)
				data["focus_x"] = current_system.x
				data["focus_y"] = current_system.y
			else
				data["focus_x"] = info["x"]
				data["focus_y"] = info["y"]
			for(var/datum/star_system/system in SSstar_system.systems)
				if(system.hidden || system.sector != current_sector)
					continue
				var/list/system_list = list()
				system_list["name"] = system.name
				if(current_system)
					system_list["in_range"] = starmap_in_range(current_system, system) || starmap_return_jump(system)
					system_list["distance"] = "[current_system.dist(system) > 0 ? "[current_system.dist(system)] l.ś." : "Jesteś tutaj."]"
				else
					system_list["in_range"] = 0
				system_list["x"] = system.x
				system_list["y"] = system.y
				system_list["star_id"] = "\ref[system]"
				system_list["is_current"] = (system == current_system)
				system_list["alignment"] = system.alignment
				system_list["visited"] = starmap_visited(system)
				system_list["hidden"] = FALSE
				var/label = ""
				if(system.is_hypergate)
					label += " HIPERBRAMA"
				if(system.is_capital && !label)
					label += "STOLICA"
				if(system.trader && system.sector != SECTOR_NEUTRAL) //Use shortnames in brazil for readability
					label += " [system.trader.name]"
				if(system.trader && system.sector == SECTOR_NEUTRAL)
					label += " [system.trader.shortname]"
				if(system.mission_sector)
					label += " ZAJĘTY"
				if(system.objective_sector)
					label += " MISJA"
				system_list["label"] = label
				for(var/thename in system.adjacency_list) //Draw the lines joining our systems
					var/datum/star_system/sys = SSstar_system.system_by_id(thename)
					if(!sys)
						message_admins("[thename] jest na liście sąsiedztwa układu, ale nie istnieje. Utwórz dla niego datum starsystem.")
						continue
					var/is_wormhole = (LAZYFIND(sys.wormhole_connections, system.name) || LAZYFIND(system.wormhole_connections, sys.name))
					var/is_bidirectional = (LAZYFIND(sys.adjacency_list, system.name) && LAZYFIND(system.adjacency_list, sys.name))
					if((!is_bidirectional && system != current_system) || sys.hidden || sys.sector != system.sector) //Secret One way wormholes show you faint, purple paths.
						continue
					var/thecolour = "#FFFFFF"
					var/opacity = 1
					if(LAZYFIND(current_system?.adjacency_list, thename) && is_wormhole) //Don't flood the map with wormhole paths, the idea is that you find them yourself!
						thecolour = "#BA55D3"
						opacity = 0.85
					var/list/line = list()
					var/dx = sys.x - system.x
					var/dy = sys.y - system.y
					var/len = sqrt(dx*dx+dy*dy)
					var/angle = 90 - ATAN2(dy, dx)
					line["x"] = system.x
					line["y"] = system.y
					line["len"] = len
					line["angle"] = -angle
					line["colour"] = thecolour
					line["priority"] = (sys != current_system) ? 1 : 2
					line["opacity"] = opacity //Wormholes show faint, purple lines.
					lines[++lines.len] = line
				systems_list[++systems_list.len] = system_list
			if(info["to_time"] > 0 && last_system && target_system)
				data["freepointer_x"] = info["x"]
				data["freepointer_y"] = info["y"]
				var/dist = last_system.dist(target_system)
				var/dx = target_system.x - last_system.x
				var/dy = target_system.y - last_system.y
				data["freepointer_cos"] = dist ? dx / dist : 1
				data["freepointer_sin"] = dist ? dy / dist : 0
				data["travelling"] = TRUE
			data["star_systems"] = systems_list
			data["lines"] = lines

		if(NAV_SCREEN_SYSTEM)
			data["star_id"] = "\ref[selected_system]"
			data["star_name"] = selected_system?.name
			data["alignment"] = capitalize(selected_system?.alignment)
			if(current_system && selected_system)
				data["star_dist"] = current_system.dist(selected_system)
				data["can_jump"] = starmap_can_jump(selected_system)
				if(!can_control_ship) //For public consoles
					data["can_jump"] = FALSE

	data["ftl_safety_override"] = linked?.ftl_safety_override
	data["screen"] = screen
	data["can_control"] = !!starmap_can_control()
	data["can_cancel"] = starmap_can_control() && linked?.ftl_drive?.ftl_state == FTL_STATE_JUMPING && linked?.ftl_drive?.can_cancel_jump && !linked?.ftl_safety_override
	return data

/// Dane zakładki „Napęd FTL”: stan napędu okrętu, a dla starego komputera FTL też to, co pokazywało jego okno
/obj/machinery/computer/ship/proc/ftl_tab_data(mob/user)
	var/list/data = list("kind" = "none")
	var/obj/drive = linked?.ftl_drive
	data["can_control"] = !!starmap_can_control()
	if(istype(drive, /obj/machinery/computer/ship/ftl_computer))
		var/obj/machinery/computer/ship/ftl_computer/legacy = drive
		data["kind"] = "legacy"
		data["name"] = legacy.name
		data["powered"] = legacy.active
		data["progress"] = legacy.progress
		data["goal"] = legacy.spoolup_time
		data["state"] = legacy.ftl_state
		data["ready"] = (legacy.ftl_state == FTL_STATE_READY)
		data["allowed"] = !!legacy.allowed(user)
		data["await_emergency_ftl_confirm"] = (legacy.await_emergency_ftl_confirm > world.time && linked.ftl_safety_override)
		var/list/ships = list()
		for(var/X in legacy.tracking)
			var/list/ship_info = list()
			ship_info["name"] = legacy.tracking[X]["name"]
			ship_info["current_system"] = legacy.tracking[X]["current_system"]
			ship_info["target_system"] = legacy.tracking[X]["target_system"]
			ships[++ships.len] = ship_info
		data["tracking"] = ships
	else if(istype(drive, /obj/machinery/computer/ship/ftl_core))
		var/obj/machinery/computer/ship/ftl_core/core = drive
		data["kind"] = "modular"
		data["name"] = core.name
		data["powered"] = core.active
		data["progress"] = core.progress
		data["goal"] = core.req_charge
		data["state"] = core.ftl_state
		data["ready"] = (core.ftl_state == FTL_STATE_READY)
		data["cooldown"] = core.cooldown
		data["pylons"] = length(core.pylons)
		data["active_pylons"] = core.get_active_pylons()
		data["await_emergency_ftl_confirm"] = (core.await_emergency_ftl_confirm > world.time && linked.ftl_safety_override)
	return data

/// Skok do wybranego układu z zakładki „Układ” (jak akcja „jump” konsoli nawigacji z core, plus sprawdzenie, czy wolno)
/obj/machinery/computer/ship/proc/starmap_jump(datum/star_system/target, mob/user)
	if(!linked?.ftl_drive || !starmap_can_control())
		return FALSE
	if(linked.ftl_drive.lockout)
		to_chat(user, "<span class='warning'>[icon2html(src, viewers(src))] Nie można wykonać. Nieprawidłowy klucz autoryzacji do odblokowania kodu nadpisania.</span>")
		return FALSE
	if(!starmap_can_jump(target))
		return FALSE
	if(linked.ftl_safety_override)
		if(linked.next_emergency_jump > world.time)
			say("Awaryjny kondensator napędu wciąż się ładuje. Skok awaryjny niedostępny.")
			return TRUE
		linked.ftl_drive.request_emergency_ftl_confirm()
	else
		linked.ftl_drive.jump(target)
	return TRUE

/// Przerwanie skoku (jak akcja „cancel_jump” konsoli nawigacji z core)
/obj/machinery/computer/ship/proc/starmap_cancel_jump(mob/user)
	if(!linked?.ftl_drive || !starmap_can_control())
		return FALSE
	if(linked.ftl_drive.lockout)
		to_chat(user, "<span class='warning'>[icon2html(src, viewers(src))] Nie można wykonać. Nieprawidłowy klucz autoryzacji do odblokowania kodu nadpisania.</span>")
		return FALSE
	if(linked.ftl_drive.cancel_ftl())
		linked.stop_relay(CHANNEL_IMPORTANT_SHIP_ALERT)
		linked.relay('nsv13/sound/effects/ship/ftl_stop.ogg', channel=CHANNEL_IMPORTANT_SHIP_ALERT)
	return TRUE

/// Sterowanie starym komputerem FTL z zakładki „Napęd FTL” innej konsoli: te same akcje i sprawdzenia co przy maszynie
/obj/machinery/computer/ship/proc/ftl_tab_act(action, list/params, datum/tgui/ui, mob/user)
	if(!starmap_can_control())
		return FALSE
	var/obj/machinery/computer/ship/ftl_computer/legacy = linked?.ftl_drive
	if(!istype(legacy))
		return FALSE
	if(!legacy.allowed(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu</span>")
		return FALSE
	legacy.ui_act(action, params, ui)
	return TRUE

// --- Konsola nawigacji ---

/obj/machinery/computer/ship/navigation/ui_data(mob/user)
	if(!has_overmap())
		return
	var/list/data = starmap_ui_data(user, screen, selected_system, current_sector, can_control_ship)
	if(merged_ftl_tab)
		data["ftl"] = ftl_tab_data(user)
		data["ftl_console"] = FALSE
	return data

/obj/machinery/computer/ship/navigation/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. && !IsAdminGhost(usr))
		return
	if(!linked || !merged_ftl_tab)
		return
	switch(action)
		if("system")
			if(selected_system)
				screen = NAV_SCREEN_SYSTEM
			return TRUE
		if("ftl_tab")
			screen = NAV_SCREEN_FTL
			return TRUE
		if("nav_jump")
			return starmap_jump(selected_system, usr)
		if("nav_cancel_jump")
			return starmap_cancel_jump(usr)
		if("toggle_power", "emergency_jump")
			return ftl_tab_act(action, params, ui, usr)

// --- Stary komputer FTL: to samo okno, zaczyna od zakładki napędu ---

/obj/machinery/computer/ship/ftl_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		nav_screen = NAV_SCREEN_FTL
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		ui = new(user, src, "Starmap")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/ftl_computer/ui_data(mob/user)
	if(!linked)
		return list()
	var/list/data = starmap_ui_data(user, nav_screen, nav_selected_system, nav_sector, TRUE)
	data["ftl"] = ftl_tab_data(user)
	data["ftl_console"] = TRUE
	return data

/obj/machinery/computer/ship/ftl_computer/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!linked)
		return
	switch(action)
		if("map")
			nav_screen = NAV_SCREEN_STARMAP
			return TRUE
		if("shipinf")
			nav_screen = NAV_SCREEN_SHIPINFO
			return TRUE
		if("system")
			if(nav_selected_system)
				nav_screen = NAV_SCREEN_SYSTEM
			return TRUE
		if("ftl_tab")
			nav_screen = NAV_SCREEN_FTL
			return TRUE
		if("sector")
			var/sector = input(usr, "Na który sektor przełączyć?", "Wybór sektora", null) as null|anything in list(ALL_STARMAP_SECTORS)
			if(!sector)
				return
			nav_sector = sector
			return TRUE
		if("select_system")
			var/datum/star_system/target = locate(params["star_id"])
			if(!istype(target))
				return
			nav_selected_system = target
			nav_screen = NAV_SCREEN_SYSTEM
			return TRUE
		if("nav_jump")
			return starmap_jump(nav_selected_system, usr)
		if("nav_cancel_jump")
			return starmap_cancel_jump(usr)

#undef NAV_SCREEN_SHIPINFO
#undef NAV_SCREEN_STARMAP
#undef NAV_SCREEN_SYSTEM
#undef NAV_SCREEN_FTL
