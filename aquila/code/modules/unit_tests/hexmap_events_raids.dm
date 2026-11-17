/// AQUILA - wypady Syndykatu z kafli hex (aquila/code/modules/events/hexmap/lone_hunter.dm): tylko na pograniczu i w sektorze
/// Syndykatu, tylko z pól asteroid i mgławic, rzadko (hex_pool_chance), a łowca wyskakuje przy okręcie, celuje w niego
/// i nie daje nagrody za zestrzelenie. Bez okrętu w układzie gwiezdnym nic się nie pojawia.
/datum/unit_test/aquila_hex_syndicate_raids
	var/datum/star_system/system
	var/obj/structure/overmap/ship
	var/list/spawned = list()

/datum/unit_test/aquila_hex_syndicate_raids/Run()
	system = new /datum/star_system(name = "Aquila hex raid test", system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS)
	system.occupying_z = run_loc_floor_bottom_left.z
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.faction = "nanotrasen"
	ship.forceMove(locate(40, 40, run_loc_floor_bottom_left.z))
	ship.current_system = system
	var/fail = check_sectors() || check_pools() || check_pool_chance() || check_lone_hunter()
	for(var/atom/movable/thing as anything in spawned)
		system.system_contents -= thing
		if(!QDELETED(thing))
			qdel(thing)
	ship.current_system = null
	QDEL_NULL(system)
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_hex_syndicate_raids/proc/check_sectors()
	var/list/expected = list("[SECTOR_SOL]" = FALSE, "[SECTOR_NEUTRAL]" = TRUE, "[SECTOR_SYNDICATE]" = TRUE)
	for(var/sector_key in expected)
		system.sector = text2num(sector_key)
		if(aquila_hex_syndicate_space(ship) != expected[sector_key])
			return "Wypady Syndykatu w sektorze [sector_key]: [aquila_hex_syndicate_space(ship) ? "dozwolone" : "zabronione"], a powinny być odwrotnie"
	if(aquila_hex_syndicate_space(null))
		return "Wypady Syndykatu dozwolone bez okrętu"

/datum/unit_test/aquila_hex_syndicate_raids/proc/check_pools()
	var/list/allowed_terrains = list(
		/datum/round_event_control/aquila_hex_lone_hunter = list(HEX_TERRAIN_ASTEROIDS, HEX_TERRAIN_NEBULA),
	)
	for(var/path in allowed_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		if(!control)
			return "Brak kontrolki eventu [path]"
		if(control.hex_pool_chance >= 100)
			return "[control.name] nie jest rzadki (hex_pool_chance [control.hex_pool_chance])"
		var/list/terrains = allowed_terrains[path]
		for(var/id in terrains)
			if(!(path in hex_terrain(id).events))
				return "[control.name] nie ma w puli kafla [id]"
		for(var/id in GLOB.hex_terrains)
			if(!(id in terrains) && (path in hex_terrain(id).events))
				return "[control.name] jest w puli kafla [id], a ma być tylko na polach asteroid i w mgławicach"

/// Event z hex_pool_chance = 0 nigdy nie wypada z puli kafla, ze 100 wypada
/datum/unit_test/aquila_hex_syndicate_raids/proc/check_pool_chance()
	var/datum/round_event_control/dust = hex_event_control(/datum/round_event_control/space_dust)
	if(!dust)
		return "Brak kontrolki pyłu kosmicznego"
	var/datum/hex/field
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(!H.system)
			field = H
			break
	if(!field)
		return "Brak pustego kafla mapy hex"
	var/saved_terrain = field.terrain
	var/saved_players = dust.min_players
	var/saved_chance = dust.hex_pool_chance
	field.terrain = HEX_TERRAIN_ASTEROIDS
	dust.min_players = 0
	dust.hex_pool_chance = 0
	var/picked_never = 0
	for(var/i in 1 to 30)
		if(hex_pick_tile_event(field, FALSE) == dust)
			picked_never++
	dust.hex_pool_chance = 100
	var/picked_always = 0
	for(var/i in 1 to 100)
		if(hex_pick_tile_event(field, FALSE) == dust)
			picked_always++
	field.terrain = saved_terrain
	dust.min_players = saved_players
	dust.hex_pool_chance = saved_chance
	if(picked_never)
		return "Pył z hex_pool_chance = 0 wypadł z puli [picked_never] razy na 30"
	if(!picked_always)
		return "Pył z hex_pool_chance = 100 nie wypadł z puli ani razu na 100"

/datum/unit_test/aquila_hex_syndicate_raids/proc/check_lone_hunter()
	var/datum/round_event/aquila_hex_lone_hunter/hunt = new /datum/round_event/aquila_hex_lone_hunter(FALSE)
	hunt.kill()
	if(hunt.endWhen - hunt.startWhen < 2 || hunt.endWhen - hunt.startWhen > 3)
		qdel(hunt)
		return "Łowca wyskakuje po [hunt.endWhen - hunt.startWhen] cyklach od ostrzeżenia zamiast po 2–3 (4–6 s)"
	ship.current_system = null
	var/obj/structure/overmap/nowhere = hunt.spawn_hunter(ship)
	ship.current_system = system
	if(nowhere)
		spawned += nowhere
		qdel(hunt)
		return "Łowca wyskoczył, choć okręt nie jest w układzie gwiezdnym"
	var/obj/structure/overmap/syndicate/ai/hunter = hunt.spawn_hunter(ship)
	qdel(hunt)
	if(!hunter)
		return "Samotny łowca się nie pojawił"
	spawned += hunter
	var/syndicate_ships = 0
	for(var/obj/structure/overmap/other in system.system_contents)
		if(other.faction == "syndicate")
			syndicate_ships++
	if(syndicate_ships != 1)
		return "W układzie jest [syndicate_ships] okrętów Syndykatu zamiast jednego łowcy"
	if(hunter.type != /obj/structure/overmap/syndicate/ai || !hunter.ai_controlled)
		return "Łowca to [hunter.type], a nie okręt Syndykatu sterowany przez AI"
	if(hunter.current_system != system)
		return "Łowca ma zły układ gwiezdny"
	var/distance = get_dist(hunter, ship)
	if(distance < 12 || distance > 16)
		return "Łowca wyskoczył [distance] pól od okrętu zamiast 12–16"
	if(hunter.last_target != ship)
		return "Łowca nie celuje w okręt"
	var/pool_before = SSstar_system.bounty_pool
	qdel(hunter)
	if(SSstar_system.bounty_pool != pool_before)
		SSstar_system.bounty_pool = pool_before
		return "Zniszczenie łowcy dodało nagrodę do puli"
