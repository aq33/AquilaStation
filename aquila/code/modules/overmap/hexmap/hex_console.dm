// AQUILA - konsola nawigacji FTL na mapie hex (okno HexStarmap.tsx). Stare okno Starmap zostaje dla astrometrii i menedżera układów.

/obj/machinery/computer/ship/navigation
	/// Zaznaczony kafel (wspólny dla wszystkich patrzących na tę konsolę)
	var/datum/hex/hex_selected
	/// Konsola pokazuje mapę hex. Astrometria dziedziczy po konsoli nawigacji i woła jej ui_data(), a jej okno zna tylko stary format
	var/hex_map_console = TRUE

/obj/machinery/computer/ship/navigation/astrometrics
	hex_map_console = FALSE

/// Czy ta konsola działa jako konsola mapy hex
/obj/machinery/computer/ship/navigation/proc/uses_hex_map()
	return hex_map_console && GLOB.hexmap?.built

/obj/machinery/computer/ship/navigation/ui_interact(mob/user, datum/tgui/ui)
	if(!linked || !uses_hex_map())
		return ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		if(!hex_selected)
			hex_selected = linked.current_hex()
		ui = new(user, src, "HexStarmap")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/navigation/ui_static_data(mob/user)
	if(!uses_hex_map())
		return ..()
	var/list/data = list()
	var/list/sector_list = list()
	for(var/sec in GLOB.hexmap?.sectors)
		var/list/dims = GLOB.hexmap.sectors[sec]
		sector_list += list(list("id" = text2num(sec), "name" = hex_sector_name(text2num(sec)), "cols" = dims["cols"], "rows" = dims["rows"]))
	data["sectors"] = sector_list
	data["cost_hex"] = HEX_FTL_COST_HEX
	data["cost_gate"] = HEX_FTL_COST_GATE
	data["cooldown"] = HEX_FTL_COOLDOWN / 10
	return data

/obj/machinery/computer/ship/navigation/ui_data(mob/user)
	if(!uses_hex_map() || !has_overmap())
		return ..()
	GLOB.hexmap.place_new_systems()
	var/list/data = list()
	var/list/info = SSstar_system.ships[linked]
	data["can_control"] = can_control_ship
	var/datum/hex/here = linked.current_hex()
	var/list/ship = list(
		"hex" = here?.id,
		"sector" = here?.sector,
		"charge" = linked.hex_charge(),
		"cooldown" = linked.hex_cooldown_left(),
		"state" = hex_drive_state_text(),
		"jumping" = linked.ftl_drive?.ftl_state == FTL_STATE_JUMPING,
		"lockout" = linked.ftl_drive?.lockout,
		"safety_override" = linked.ftl_safety_override,
		"in_transit" = FALSE,
	)
	if(info?["target_system"])
		SSstar_system.update_pos(linked)
		var/datum/star_system/from_sys = info["last_system"]
		var/datum/star_system/to_sys = info["target_system"]
		var/datum/hex/from_hex = GLOB.hexmap.hex_of_system(from_sys)
		var/datum/hex/to_hex = GLOB.hexmap.hex_of_system(to_sys)
		ship["in_transit"] = TRUE
		ship["from"] = from_hex?.display_name() || from_sys?.name
		ship["from_hex"] = from_hex?.id
		ship["to"] = to_hex?.display_name() || to_sys?.name
		ship["to_hex"] = to_hex?.id
		ship["time_left"] = max(0, round((info["to_time"] - world.time) / 10, 1))
	data["ship"] = ship

	var/list/systems_out = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random/hex_empty))
			continue
		var/list/gate_names = list()
		for(var/datum/hex/G as anything in S.hex.gates)
			gate_names += G.display_name()
		systems_out += list(list(
			"name" = S.name,
			"hex" = S.hex.id,
			"sector" = S.hex.sector,
			"col" = S.hex.col,
			"row" = S.hex.row,
			"alignment" = S.alignment,
			"owner" = S.owner,
			"capital" = S.is_capital,
			"hypergate" = S.is_hypergate,
			"trader" = S.trader?.name,
			"type" = S.system_type?["label"],
			"gates" = gate_names,
			"badlands" = istype(S, /datum/star_system/random),
		))
	data["systems"] = systems_out

	// Floty AI na kaflach, także w drodze przez puste kafle (mgła wojny dopiero w PR D)
	var/list/fleets_out = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || !length(S.fleets))
			continue
		if(S.hidden && !istype(S, /datum/star_system/random/hex_empty))
			continue
		for(var/datum/fleet/F as anything in S.fleets)
			fleets_out += list(list(
				"hex" = S.hex.id,
				"name" = F.name,
				"alignment" = F.alignment,
				"ships" = F.instantiated ? length(F.all_ships) : F.size,
				"heading" = F.hex_heading?.hex?.id,
			))
	data["fleets"] = fleets_out

	var/list/gates = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || !LAZYLEN(S.hex.gates))
			continue
		for(var/datum/hex/G as anything in S.hex.gates)
			if(S.hex.id < G.id)
				gates += list(list("a" = S.hex.id, "b" = G.id))
	data["gates"] = gates

	// Zasięg: kafle, na które okręt może skoczyć teraz
	var/list/reach = list()
	if(here && !ship["in_transit"] && !linked.hex_cooldown_left() && !ship["jumping"])
		var/list/costs = GLOB.hexmap.reachable(here, linked.faction, linked.hex_charge())
		for(var/datum/hex/H as anything in costs)
			reach[H.id] = costs[H]
	data["reach"] = reach

	data["selected"] = hex_selected_data(here)
	return data

/obj/machinery/computer/ship/navigation/proc/hex_drive_state_text()
	var/obj/machinery/computer/ship/ftl_core/drive = linked.ftl_drive
	if(!drive)
		return "brak napędu"
	if(drive.ftl_state == FTL_STATE_JUMPING)
		return "rozruch skoku"
	if(linked.hex_cooldown_left())
		return "chłodzenie"
	if(!drive.active)
		return "wyłączony"
	if(drive.ftl_state == FTL_STATE_READY)
		return "naładowany"
	return "ładowanie"

/obj/machinery/computer/ship/navigation/proc/hex_selected_data(datum/hex/here)
	var/datum/hex/H = hex_selected
	if(!H)
		return null
	var/datum/star_system/S = H.system
	var/is_real = S && !istype(S, /datum/star_system/random/hex_empty)
	var/list/out = list(
		"hex" = H.id,
		"sector" = H.sector,
		"col" = H.col,
		"row" = H.row,
		"name" = H.display_name(),
		"system" = is_real,
		"desc" = is_real ? S.desc : null,
		"alignment" = is_real ? S.alignment : null,
		"owner" = is_real ? S.owner : null,
		"trader" = is_real ? S.trader?.name : null,
		"type" = is_real ? S.system_type?["label"] : null,
		"capital" = is_real && S.is_capital,
	)
	var/list/gate_names = list()
	for(var/datum/hex/G as anything in H.gates)
		gate_names += list(list("name" = G.display_name(), "hex" = G.id, "sector" = G.sector, "open" = GLOB.hexmap.gate_open(H, linked.faction)))
	out["gates"] = gate_names
	if(here && here != H)
		var/list/route = GLOB.hexmap.route(here, H, linked.faction)
		if(route)
			var/list/path_ids = list()
			for(var/datum/hex/P as anything in route["path"])
				path_ids += P.id
			var/list/full_ids = list()
			for(var/datum/hex/P as anything in route["full"])
				full_ids += P.id
			var/datum/hex/stopped = route["stopped"]
			out["route"] = list(
				"path" = path_ids,
				"full" = full_ids,
				"cost" = route["cost"],
				"hexes" = route["hexes"],
				"stopped" = stopped?.id,
				"stopped_name" = stopped?.display_name(),
				"blocker" = linked.hex_jump_blocker(route["cost"]),
			)
		else
			out["route"] = list("none" = TRUE)
	return out

/obj/machinery/computer/ship/navigation/ui_act(action, params, datum/tgui/ui)
	if(!uses_hex_map() || !(action in list("hex_select", "hex_jump", "hex_cancel")))
		return ..()
	if(!linked)
		return
	if(!can_interact(usr) && !IsAdminGhost(usr))
		return
	switch(action)
		if("hex_select")
			var/datum/hex/H = GLOB.hexmap.hex_by_id(params["hex"])
			if(!H)
				return
			hex_selected = H
			return TRUE
		if("hex_jump")
			if(!can_control_ship)
				return
			if(linked.ftl_drive?.lockout)
				to_chat(usr, "<span class='warning'>[icon2html(src, viewers(src))] Nie można wykonać. Nieprawidłowy klucz autoryzacji do odblokowania kodu nadpisania.</span>")
				return
			if(linked.ftl_safety_override)
				if(linked.next_emergency_jump > world.time)
					say("Awaryjny kondensator napędu wciąż się ładuje. Skok awaryjny niedostępny.")
					return TRUE
				linked.ftl_drive.request_emergency_ftl_confirm()
				return TRUE
			if(linked.hex_jump(hex_selected, usr))
				playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 50, TRUE)
			return TRUE
		if("hex_cancel")
			if(!can_control_ship || linked.ftl_drive?.lockout)
				return
			if(linked.hex_cancel_jump())
				linked.stop_relay(CHANNEL_IMPORTANT_SHIP_ALERT)
				linked.relay('nsv13/sound/effects/ship/ftl_stop.ogg', channel=CHANNEL_IMPORTANT_SHIP_ALERT)
				linked.ftl_drive.radio.talk_into(linked.ftl_drive, "Anulowano translację FTL. Ładunek zachowany.", linked.ftl_drive.radio_channel)
			return TRUE
