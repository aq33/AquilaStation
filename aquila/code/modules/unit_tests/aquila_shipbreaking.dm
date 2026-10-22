// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Każdy wrak mieści się w klatce magnesu, ładuje się do strefy złomowania bez rzeczy, które mogłyby ożyć,
/// ściana wraku daje złom, a recykler zamienia złom na kredyty zaopatrzenia
/datum/unit_test/shipbreaking

/datum/unit_test/shipbreaking/Run()
	// Jak w mining_asteroids: auxmos nie może ruszać turfów podmienianych przez ładowanie wielu map pod rząd
	SSair.can_fire = FALSE
	UNTIL(!SSair.thread_running())
	sleep(1 SECONDS)
	SScallbacks.can_fire = FALSE
	var/error = check_wrecks() || check_magnet()
	SScallbacks.can_fire = TRUE
	SSair.can_fire = TRUE
	TEST_ASSERT(!error, error)

/// Zwraca opis pierwszego błędu albo null
/datum/unit_test/shipbreaking/proc/check_wrecks()
	var/static/list/forbidden = typecacheof(list(/obj/docking_port, /mob/living, /obj/machinery/porta_turret, /obj/machinery/computer/ship, /obj/machinery/computer/shuttle_flight, /obj/machinery/power/apc, /obj/machinery/nuclearbomb, /obj/item/gun, /obj/effect/landmark))
	var/list/templates = get_shipbreaker_templates()
	if(!length(templates))
		return "No shipbreaker templates"
	var/turf/test_wall
	for(var/datum/map_template/shipbreaker/template as anything in templates)
		if(template.width > 30 || template.height > 30)
			return "[template.mappath] is [template.width]x[template.height], too big for the 40x40 magnet cage with room for blasts"
		// Bez Release(), patrz mining_asteroids
		var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(template.width + 1, template.height + 1)
		if(!reservation)
			return "Could not reserve space for [template.mappath]"
		var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
		if(!template.load(bottom_left))
			return "[template.mappath] failed to load"
		var/hull = 0
		for(var/turf/T as anything in template.get_affected_turfs(bottom_left))
			if(isgroundlessturf(T))
				continue
			hull++
			if(!is_shipbreak_area(T))
				return "[template.mappath] has [T] at [T.x],[T.y] outside the shipbreaking area ([get_area(T)])"
			for(var/atom/movable/AM as anything in T)
				if(is_type_in_typecache(AM, forbidden))
					return "[template.mappath] still has [AM.type] at [T.x],[T.y]"
			if(!test_wall && istype(T, /turf/closed/wall) && !istype(T, /turf/closed/wall/r_wall))
				test_wall = T
		if(!hull)
			return "[template.mappath] loaded nothing"

	if(!test_wall)
		return "No plain wall in any wreck to test scrap drops"
	var/turf/closed/wall/wall = test_wall
	var/turf/wall_turf = wall
	var/scrap_type = wall.scrap_type
	wall.dismantle_wall()
	var/obj/item/stack/scrap/dropped = locate(scrap_type) in wall_turf
	if(!dropped)
		return "Dismantling a wreck wall did not drop [scrap_type]"
	qdel(dropped) // żeby nowy złom nie scalił się z tym stosem

	var/obj/machinery/shipbreaker/recycler = new(wall_turf)
	recycler.set_machine_stat(recycler.machine_stat & ~NOPOWER) // strefa złomowania to kosmos bez prądu
	var/datum/bank_account/budget = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/money_before = budget.account_balance
	var/obj/item/stack/scrap/plating/plating = new(null, 5)
	var/expected = plating.amount * plating.scrap_value
	plating.forceMove(wall_turf)
	if(!QDELETED(plating))
		return "Recycler did not eat the scrap"
	if(budget.account_balance - money_before != expected)
		return "Recycler paid [budget.account_balance - money_before] instead of [expected]"
	qdel(recycler)

/// Magnes na mapie CI łapie wrak do klatki i potem czyści ją do stanu sprzed wraku
/datum/unit_test/shipbreaking/proc/check_magnet()
	var/obj/machinery/computer/ship/mineral_magnet/magnet
	for(var/obj/machinery/computer/ship/mineral_magnet/candidate in GLOB.machines)
		if(candidate.target_location && candidate.has_overmap())
			magnet = candidate
			break
	if(!magnet)
		if(length(GLOB.asteroid_spawn_markers))
			return "The map has a magnet cage, but no magnet console linked to it and to the ship"
		return // mapa bez klatki
	var/area/old_area = get_area(magnet.target_location)
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = new(get_turf(magnet.linked))
	magnet.cooldown = FALSE
	if(!magnet.pull_in_wreck(null, wreck))
		return "Magnet refused to pull a wreck"
	if(!magnet.load_wreck())
		return "Magnet failed to load [magnet.current_wreck?.mappath]"
	var/health = magnet.get_wreck_health()
	if(!health)
		return "Freshly loaded wreck reports [health]% health"
	magnet.push_away_asteroid()
	if(magnet.current_wreck)
		return "Wreck still set after pushing it away"
	for(var/turf/T as anything in magnet.get_cage_turfs())
		if(is_shipbreak_area(T))
			return "Cage turf [T.x],[T.y] stayed in the shipbreaking area after the push"
		if(!isspaceturf(T))
			return "Cage turf [T.x],[T.y] is [T.type] after the push"
	if(get_area(magnet.target_location) != old_area)
		return "Cage area changed from [old_area] to [get_area(magnet.target_location)]"

#undef TEST_ASSERT
