// AQUILA - zapis wojny w kampanii (część D): floty sztabów, konwoje, magazyny obiektów i dowódcy przechodzą do
// następnej rundy w hexmap.json. Garnizony układów (floty FLEET_TRAIT_DEFENSE) odradzają się co rundę jak dotąd.

/datum/hex_war/proc/serialize()
	var/list/commander_data = list()
	for(var/datum/hex_commander/C as anything in commanders)
		commander_data += list(list(
			"id" = C.id,
			"faction" = C.faction,
			"first" = C.first_name,
			"last" = C.last_name,
			"nick" = C.nickname,
			"rank" = C.rank,
			"traits" = C.traits,
			"known" = C.known_traits,
			"wins" = C.wins,
			"losses" = C.losses,
			"status" = C.status,
			"grudge" = C.grudge,
			"scars" = C.scars,
			"history" = C.history,
			"seen" = C.seen,
			"return_in" = max(0, C.return_at - world.time),
		))
	var/list/fleet_data = list()
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(!F.war_controlled)
			continue
		var/datum/hex/H = GLOB.hexmap.hex_of_system(F.current_system)
		if(!H)
			continue
		fleet_data += list(list(
			"type" = "[F.type]",
			"alignment" = F.alignment,
			"hex" = H.id,
			"ships" = F.hex_war_ship_count(),
			"max_ships" = F.war_max_ships,
			"strength" = F.hex_war_strength(),
			"order" = F.war_order,
			"target" = F.war_target?.hex?.id,
			"commander" = F.commander?.id,
			"loot" = F.war_loot,
			"cargo" = F.war_cargo,
			"cargo_amount" = F.war_cargo_amount,
			"destination" = F.war_destination?.hex?.id,
		))
	var/list/stores = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.war_ore || S.war_parts)
			stores[S.name] = list(S.war_ore, S.war_parts)
	return list("commanders" = commander_data, "fleets" = fleet_data, "stores" = stores, "next_id" = next_commander_id)

/// Odtwarza wojnę z zapisu. Zwraca FALSE, gdy zapisu nie da się użyć (wtedy sztab przejmuje floty ze startu rundy).
/datum/hex_war/proc/restore(list/saved)
	var/list/fleet_data = saved["fleets"]
	if(!islist(fleet_data) || !length(fleet_data))
		return FALSE
	next_commander_id = max(1, saved["next_id"])
	var/list/by_id = list()
	for(var/list/entry in saved["commanders"])
		var/datum/hex_commander/C = new
		C.id = entry["id"]
		C.faction = entry["faction"]
		C.first_name = entry["first"]
		C.last_name = entry["last"]
		C.nickname = entry["nick"]
		C.rank = entry["rank"]
		C.traits = islist(entry["traits"]) ? entry["traits"] : list()
		C.known_traits = islist(entry["known"]) ? entry["known"] : list()
		C.wins = entry["wins"]
		C.losses = entry["losses"]
		C.status = entry["status"] || HEX_CMD_ACTIVE
		C.grudge = entry["grudge"]
		C.scars = islist(entry["scars"]) ? entry["scars"] : list()
		C.history = islist(entry["history"]) ? entry["history"] : list()
		C.seen = entry["seen"]
		C.return_at = world.time + entry["return_in"]
		commanders += C
		by_id["[C.id]"] = C
		next_commander_id = max(next_commander_id, C.id + 1)
	// Floty, które sztab przejąłby ze startu rundy, zastępuje zapis
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(F.hex_war_adoptable())
			F.hex_war_dispose()
	for(var/list/entry in fleet_data)
		restore_fleet(entry, by_id)
	var/list/stores = saved["stores"]
	if(islist(stores))
		for(var/name in stores)
			var/datum/star_system/S = SSstar_system.system_by_id(name)
			var/list/values = stores[name]
			if(S && islist(values) && length(values) >= 2)
				S.war_ore = values[1]
				S.war_parts = values[2]
	// Dowódca, którego flota nie wróciła (np. kafel zniknął z mapy), wraca jako ranny
	for(var/datum/hex_commander/C as anything in commanders)
		if(C.status == HEX_CMD_ACTIVE && !C.fleet)
			C.status = HEX_CMD_WOUNDED
			C.return_at = world.time + rand(HEX_WAR_RETURN_MIN, HEX_WAR_RETURN_MAX)
	log_game("HEXWAR: restored [length(fleet_data)] fleets and [length(commanders)] commanders from the campaign save")
	return TRUE

/datum/hex_war/proc/restore_fleet(list/entry, list/by_id)
	var/fleet_type = text2path(entry["type"])
	var/datum/hex/H = GLOB.hexmap.hex_by_id(entry["hex"])
	if(!ispath(fleet_type, /datum/fleet) || !H || GLOB.hexmap.blocks(H))
		return
	var/datum/star_system/S = GLOB.hexmap.system_for(H)
	var/ships = max(1, entry["ships"])
	var/datum/fleet/F
	if(entry["cargo"])
		var/datum/hex/dest_hex = GLOB.hexmap.hex_by_id(entry["destination"])
		if(!dest_hex?.system || !send_convoy(S, entry["alignment"], entry["cargo"], entry["cargo_amount"], null, dest_hex.system))
			return
		F = S.fleets[length(S.fleets)]
	else
		F = S.spawn_fleet(fleet_type, max(2, ships))
		if(!F)
			return
		var/datum/hex_commander/C = by_id["[entry["commander"]]"]
		F.hex_war_adopt(C)
		F.war_loot = entry["loot"]
	// Tyle okrętów i taki stan kadłubów, jaki flota miała na koniec rundy
	var/list/live = list()
	for(var/obj/structure/overmap/OM as anything in F.all_ships)
		if(!QDELETED(OM))
			live += OM
	while(length(live) > ships)
		var/obj/structure/overmap/extra = live[length(live)]
		live.len--
		qdel(extra)
	if(length(live) < ships)
		F.hex_war_add_ships(ships - length(live))
	var/strength = clamp(entry["strength"] || 1, 0.1, 1)
	for(var/obj/structure/overmap/OM as anything in F.all_ships)
		if(!QDELETED(OM))
			OM.obj_integrity = max(1, OM.max_integrity * strength)
	F.war_max_ships = max(entry["max_ships"], F.hex_war_ship_count())
	var/datum/hex/target_hex = GLOB.hexmap.hex_by_id(entry["target"])
	if(!entry["cargo"])
		F.hex_war_set_order(entry["order"] || HEX_ORDER_IDLE, target_hex ? GLOB.hexmap.system_for(target_hex) : null)
