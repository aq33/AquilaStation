// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zniszczona jednostka wysadza tylko własne wnętrze, a nie losowe pole w innym obszarze tego samego typu.
/// Dwa Sabre mają osobne instancje /area/shuttle/sabre: usunięcie jednego wysadzało (siła 7) wnętrze drugiego,
/// także tego w locie, i np. ster znikał z kokpitu (losowa porażka sabre_shuttle_rotated w CI)
/datum/unit_test/overmap_explode_own_area
	/// Epicentra wybuchów, które zaczęły się w trakcie testu
	var/list/epicenters = list()
	// Wszystko, co test postawił na mapie: Destroy() zwalnia to także wtedy, gdy asercja przerwie Run()
	var/datum/turf_reservation/hangar
	var/list/obj/docking_port/stationary/sabre/mining/ports = list()
	var/list/obj/docking_port/mobile/sabre/interiors = list()
	var/list/obj/structure/overmap/small_craft/transport/sabre/shuttle/crafts = list()
	/// Parking drugiego Sabre: jednostka bez wnętrza nie sprząta go po sobie
	var/obj/docking_port/stationary/parking
	var/datum/turf_reservation/parking_reservation

/datum/unit_test/overmap_explode_own_area/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	// Najpierw jednostki (ta w locie zabiera wnętrze i parking ze sobą), potem wnętrza, które zostały w dokach
	for(var/obj/structure/overmap/craft as anything in crafts)
		if(!QDELETED(craft))
			qdel(craft)
	for(var/obj/docking_port/mobile/interior as anything in interiors)
		if(!QDELETED(interior))
			interior.jumpToNullSpace()
	if(!QDELETED(parking))
		qdel(parking, TRUE)
	if(!QDELETED(parking_reservation))
		qdel(parking_reservation)
	for(var/obj/docking_port/stationary/port as anything in ports)
		if(!QDELETED(port))
			qdel(port, TRUE)
	if(!QDELETED(hangar))
		qdel(hangar)
	crafts = null
	interiors = null
	ports = null
	parking = null
	parking_reservation = null
	hangar = null
	return ..()

/datum/unit_test/overmap_explode_own_area/proc/on_explosion(datum/source, turf/epicenter)
	SIGNAL_HANDLER
	epicenters += epicenter

/datum/unit_test/overmap_explode_own_area/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to dock at")
	hangar = SSmapping.RequestBlockReservation(30, 30)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	// Wczytanie szablonu usypia, więc new() wraca przed zadokowaniem; drugi port dopiero po pierwszym
	for(var/index in 1 to 2)
		var/obj/docking_port/stationary/sabre/mining/port = new(locate(bl[1] + 1 + (index - 1) * 14, bl[2] + 1, bl[3]))
		ports += port
		var/timeout = world.time + 30 SECONDS
		while(!port.docked && world.time < timeout)
			sleep(1)
		var/obj/docking_port/mobile/sabre/interior = port.docked
		if(istype(interior))
			interiors += interior
			if(interior.craft)
				crafts += interior.craft
		TEST_ASSERT(length(crafts) == index, "Sabre [index] didn't dock at its port with a craft")
	var/area/first_area = crafts[1].linked_areas[1]
	var/area/second_area = crafts[2].linked_areas[1]
	TEST_ASSERT(first_area != second_area && first_area.type == second_area.type, "The two Sabre interiors should be separate areas of one type")

	// Drugi Sabre startuje (jednostka na overmapie, wnętrze na parkingu), traci wnętrze i ginie: nie ma już czego
	// wysadzać, a pierwszy stoi w hangarze nietknięty. Jednostka w doku stoi na polu włazu we własnym wnętrzu,
	// więc zginęłaby razem z nim i wybuch trafiłby jeszcze w jej własne pola
	crafts[2].set_fuel(500)
	TEST_ASSERT(crafts[2].shuttle_launch(), "The second Sabre didn't launch")
	parking = crafts[2].shuttle_parking
	parking_reservation = crafts[2].shuttle_parking_reservation
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(on_explosion))
	interiors[2].jumpToNullSpace()
	qdel(crafts[2])
	var/turf/wrong = length(epicenters) ? epicenters[1] : null
	TEST_ASSERT(!wrong, "Deleting a Sabre with no interior left started an explosion in [wrong ? "[get_area(wrong)] [AREACOORD(wrong)]" : "nowhere"]")

	// Pierwszy Sabre ginie z wnętrzem: wybuch jest w jego własnym wnętrzu
	qdel(crafts[1])
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	TEST_ASSERT(length(epicenters) == 1, "Deleting a Sabre with its interior started [length(epicenters)] explosions, expected 1")
	var/turf/epicenter = epicenters[1]
	TEST_ASSERT(get_area(epicenter) == first_area, "The destroyed Sabre blew up [get_area(epicenter)] [AREACOORD(epicenter)], not its own interior")

#undef TEST_ASSERT
