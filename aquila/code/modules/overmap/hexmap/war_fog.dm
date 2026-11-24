// AQUILA - mgła wojny w konsoli nawigacji (część D): wrogie floty i konwoje widać tylko w zasięgu sensorów okrętu,
// przy sojuszniczych układach i flotach oraz w zasięgu placówek nasłuchowych. Poza nim zostaje ostatnia znana pozycja.

/// Kafle widoczne dla okrętu (hex -> TRUE), liczone najwyżej raz na 5 s
/proc/hex_fog_visible(obj/structure/overmap/ship)
	var/static/list/cache
	var/static/cache_time = 0
	var/static/cache_ship
	if(cache && world.time < cache_time + 5 SECONDS && cache_ship == ship)
		return cache
	var/list/visible = list()
	var/faction = ship?.faction || "nanotrasen"
	var/datum/hex/here = ship?.current_hex()
	if(!here && ship)
		here = GLOB.hexmap.hex_of_system(SSstar_system.ships[ship]?["last_system"])
	hex_fog_add(visible, here, HEX_FOG_SHIP)
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || istype(S, /datum/star_system/random/hex_empty) || !hex_factions_allied(faction, S.alignment))
			continue
		hex_fog_add(visible, S.hex, S.has_facility(HEX_FAC_POST) ? HEX_FOG_POST : HEX_FOG_ALLY)
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(hex_factions_allied(faction, F.alignment))
			hex_fog_add(visible, F.current_system?.hex, HEX_FOG_ALLY)
	cache = visible
	cache_time = world.time
	cache_ship = ship
	return visible

/proc/hex_fog_add(list/visible, datum/hex/center, radius)
	if(!center)
		return
	visible[center] = TRUE
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(center, radius))
		visible[H] = TRUE

/// Dane flot do okna: sojusznicze zawsze, wrogie w zasięgu, poza nim ostatnia znana pozycja (szara)
/proc/hex_fog_fleet_data(obj/structure/overmap/ship)
	. = list()
	var/list/visible = hex_fog_visible(ship)
	var/faction = ship?.faction || "nanotrasen"
	for(var/datum/fleet/F as anything in hex_all_fleets())
		var/datum/star_system/S = F.current_system
		if(!S?.hex || (S.hidden && !istype(S, /datum/star_system/random/hex_empty)))
			continue
		var/allied = hex_factions_allied(faction, F.alignment)
		var/seen_now = allied || visible[S.hex]
		var/hex_id = S.hex.id
		if(seen_now)
			F.war_last_seen_hex = hex_id
			F.war_last_seen_time = world.time
			F.war_last_seen_ships = F.hex_war_ship_count()
			if(F.commander)
				F.commander.seen = TRUE
		else if(F.war_last_seen_hex)
			hex_id = F.war_last_seen_hex
		else
			continue
		. += list(list(
			"hex" = hex_id,
			"name" = F.name,
			"alignment" = F.alignment,
			"ships" = seen_now ? F.hex_war_ship_count() : F.war_last_seen_ships, // niewidoczna flota: liczebność z ostatniej obserwacji
			"heading" = (seen_now && allied) ? (F.war_target?.hex?.id || F.hex_heading?.hex?.id) : null,
			"convoy" = !!F.war_cargo,
			"ghost" = !seen_now,
			"seen_ago" = seen_now ? 0 : round((world.time - F.war_last_seen_time) / 600),
			"order" = allied ? F.war_order : null,
			"commander" = F.commander?.id,
		))

/// Dowódcy, których flotę załoga widziała, do zakładki „Dowódcy”
/proc/hex_commander_data()
	. = list()
	for(var/datum/hex_commander/C as anything in GLOB.hex_war?.commanders)
		if(!C.seen)
			continue
		var/list/traits = list()
		for(var/id in C.traits)
			var/list/info = GLOB.hex_commander_traits[id]
			var/known = (id in C.known_traits) || hex_factions_allied("nanotrasen", C.faction)
			traits += list(list("name" = known ? info[1] : null, "kind" = known ? info[2] : null, "desc" = known ? info[3] : null))
		. += list(list(
			"id" = C.id,
			"name" = C.full_name(),
			"rank" = C.rank_name(),
			"stars" = C.rank,
			"faction" = C.faction,
			"status" = C.status,
			"wins" = C.wins,
			"losses" = C.losses,
			"grudge" = C.grudge,
			"traits" = traits,
			"scars" = C.scars,
			"history" = C.history,
			"fleet_hex" = C.fleet?.war_last_seen_hex,
			"nemesis" = !!C.nemesis,
		))
