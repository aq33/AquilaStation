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
	// Test trwa ponad minutę, a losowe zdarzenia rundy (meteory, immovable rod) potrafiły zabić złomiarza w trakcie cięcia
	// Tak samo pożary podłogi (zapalona spawarka nad plamą oleju we wraku) potrafiły przerwać cięcie
	var/events_could_fire = SSevents.can_fire
	var/fires_could_fire = SSturf_fire.can_fire
	SSevents.can_fire = FALSE
	SSturf_fire.can_fire = FALSE
	var/error = check_wrecks() || check_magnet()
	SSevents.can_fire = events_could_fire
	SSturf_fire.can_fire = fires_could_fire
	SScallbacks.can_fire = TRUE
	SSair.can_fire = TRUE
	TEST_ASSERT(!error, error)

/// Zwraca opis pierwszego błędu albo null
/datum/unit_test/shipbreaking/proc/check_wrecks()
	// Rzeczy, które działają globalnie albo strzelają do ludzi, nawet bez prądu w strefie
	var/static/list/forbidden = typecacheof(list(/obj/docking_port, /mob/living, /obj/machinery/porta_turret, /obj/machinery/computer/ship, /obj/machinery/computer/shuttle_flight, /obj/machinery/computer/emergency_shuttle, /obj/machinery/computer/piratepad_control, /obj/machinery/computer/launchpad, /obj/machinery/shuttle_scrambler, /obj/machinery/piratepad, /obj/machinery/launchpad, /obj/machinery/telecomms, /obj/machinery/power/apc, /obj/machinery/nuclearbomb, /obj/item/gun, /obj/effect/landmark))
	// Kadłub ma się dać rozebrać, a w klatce nie może być pól tranzytowych
	var/static/list/forbidden_turfs = typecacheof(list(/turf/closed/indestructible, /turf/open/indestructible, /turf/open/space/transit))
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
		// Najpierw cięcie, żeby ściana do testu złomu poniżej była jeszcze cała
		var/cut_error = check_rayne_cutting(template.get_affected_turfs(bottom_left), template.mappath)
		if(cut_error)
			return cut_error
		var/hull = 0
		for(var/turf/T as anything in template.get_affected_turfs(bottom_left))
			if(is_type_in_typecache(T, forbidden_turfs))
				return "[template.mappath] has [T.type] at [T.x],[T.y], which can't be broken down"
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
	var/list/areas_before = list()
	for(var/turf/T as anything in magnet.get_cage_turfs())
		areas_before[T] = T.loc
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = new(get_turf(magnet.linked))
	magnet.cooldown = FALSE
	if(!magnet.pull_in_wreck(null, wreck))
		return "Magnet refused to pull a wreck"
	if(!magnet.load_wreck())
		return "Magnet failed to load [magnet.current_wreck?.mappath]"
	var/health = magnet.get_wreck_health()
	if(!health)
		return "Freshly loaded wreck reports [health]% health"
	for(var/turf/T as anything in magnet.get_cage_turfs())
		if(!is_shipbreak_area(T))
			return "Cage turf [T.x],[T.y] is not in the shipbreaking area while a wreck is loaded"
	var/error = check_rayne_cutting(magnet.wreck_turfs, magnet.current_wreck.mappath, TRUE)
	magnet.push_away_asteroid()
	if(error)
		return error
	if(magnet.current_wreck)
		return "Wreck still set after pushing it away"
	for(var/turf/T as anything in magnet.get_cage_turfs())
		if(is_shipbreak_area(T))
			return "Cage turf [T.x],[T.y] stayed in the shipbreaking area after the push"
		if(!isspaceturf(T))
			return "Cage turf [T.x],[T.y] is [T.type] after the push"
		if(T.loc != areas_before[T])
			return "Cage turf [T.x],[T.y] went back to [T.loc] instead of [areas_before[T]]"

/// Spawarka Rayne tnie ścianę wraku aż do próżni (ściana, dźwigar, poszycie), a z test_engine rozbiera też silnik na rdzeń
/datum/unit_test/shipbreaking/proc/check_rayne_cutting(list/turfs, wreck_name, test_engine = FALSE)
	// Ściana wraku z podłogą obok, na której stanie złomiarz: najlepiej pustą (np. łóżko stazy unieruchamia),
	// potem przechodnią, a w ciasnych myśliwcach choćby zastawioną
	var/turf/closed/wall/wall
	var/turf/open/stand
	for(var/strictness in list(2, 1, 0))
		for(var/turf/closed/wall/candidate in turfs)
			for(var/turf/open/floor/neighbour in get_adjacent_open_turfs(candidate))
				if(strictness >= 1 && is_blocked_turf(neighbour, TRUE))
					continue
				if(strictness == 2 && ((locate(/obj/machinery) in neighbour) || (locate(/obj/structure) in neighbour)))
					continue
				wall = candidate
				stand = neighbour
				break
			if(wall)
				break
		if(wall)
			break
	if(!wall)
		return "No wreck wall with free floor next to it in [wreck_name]"
	var/mob/living/carbon/human/breaker = allocate(/mob/living/carbon/human, stand)
	breaker.status_flags |= GODMODE // wrak po wybuchach bywa bez powietrza
	ADD_TRAIT(breaker, TRAIT_STUNIMMUNE, "shipbreaking_test") // losowe zdarzenia rundy potrafią ogłuszyć w trakcie testu
	var/obj/item/weldingtool/experimental/rayne/welder = allocate(/obj/item/weldingtool/experimental/rayne, stand)
	breaker.put_in_active_hand(welder)
	welder.switched_on(breaker)
	if(!welder.isOn())
		return "Rayne welder did not turn on in the shipbreaking area"
	var/turf/target = wall
	var/list/steps = list("wall", "girder", "plating")
	for(var/step in steps)
		var/atom/to_cut = step == "girder" ? (locate(/obj/structure/girder) in target) : target
		if(!to_cut)
			return "No [step] left on [target.x],[target.y] after the previous cut"
		var/type_before = to_cut.type
		breaker.SetAllImmobility(0)
		breaker.SetUnconscious(0)
		breaker.ExtinguishMob()
		for(var/turf/near as anything in RANGE_TURFS(1, stand))
			for(var/obj/effect/abstract/turf_fire/fire in near)
				qdel(fire)
		if(!welder.cut_down(breaker, to_cut))
			return "Rayne welder failed to cut the [step] ([type_before]) at [target.x],[target.y] in [wreck_name]; breaker at [breaker.x],[breaker.y] stat [breaker.stat], incapacitated [breaker.incapacitated()] stasis [breaker.IsInStasis()] stun [breaker.IsStun()] paralyze [breaker.IsParalyzed()] unconscious [breaker.IsUnconscious()] restrained [breaker.restrained()] on tile: [english_list(stand.contents)], welder on [welder.isOn()] fuel [welder.get_fuel()]"
	if(!isspaceturf(target))
		return "Rayne welder left [target.type] instead of space after cutting a wall down in [wreck_name]"
	if(!(locate(/obj/item/stack/scrap/framing) in target) || !(locate(/obj/item/stack/scrap/plating) in target))
		return "Cutting a wall down in [wreck_name] did not drop plating and framing scrap"
	if(!test_engine)
		qdel(breaker) // inaczej sprawdzenie wraku znalazłoby na nim żywego moba
		qdel(welder)
		return

	var/obj/structure/shuttle/engine/heater/engine = new(stand)
	welder.cut_down(breaker, engine)
	if(!QDELETED(engine))
		return "Rayne welder did not cut a shuttle engine apart"
	if(!(locate(/obj/item/stack/scrap/core) in stand))
		return "Cutting an engine did not drop a ship core"

#undef TEST_ASSERT
