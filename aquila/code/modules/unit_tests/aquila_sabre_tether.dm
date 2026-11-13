// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Sabre tworzony przez port (poza wczytaniem mapy) ma uwiąz FTL do okrętu macierzystego, po starcie od razu
/// dokuje, po lądowaniu nie gra pętla alarmu, a ręcznie wybrane i obrócone miejsce lądowania pasuje do obrysu z kamery
/datum/unit_test/sabre_ftl_tether

/datum/unit_test/sabre_ftl_tether/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system, "No main ship in a star system to launch from")
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(60, 60)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	var/obj/docking_port/stationary/sabre/mining/port = new(locate(bl[1] + 40, bl[2] + 40, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!port.docked && world.time < timeout)
		sleep(1)
	var/obj/docking_port/mobile/sabre/shuttle_port = port.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock at its port")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	TEST_ASSERT(istype(sabre), "The Sabre port created no overmap craft")
	var/obj/item/fighter_component/ftl/ftl = sabre.loadout.get_slot(HARDPOINT_SLOT_FTL)
	TEST_ASSERT(ftl, "The Sabre has no FTL drive")

	// Uwiąz od razu po utworzeniu, bez LateInitialize z wczytania mapy
	TEST_ASSERT_EQUAL(ftl.anchored_to, host, "A Sabre created by its port isn't tethered to the mothership")
	TEST_ASSERT_EQUAL(sabre.ftl_home_overmap(), host, "The Sabre doesn't know the ship of its home port")

	// W doku „Powrót” mówi, że trzeba najpierw wystartować (a nie że uwiąz zginął)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human)
	ftl.ftl_state = FTL_STATE_READY
	TEST_ASSERT(!sabre.can_return_jump(pilot), "The docked Sabre allows a return jump")

	// Start z portu domowego odnawia zgubiony uwiąz i włącza tryb dokowania
	ftl.anchored_to = null
	ftl.ftl_state = FTL_STATE_IDLE
	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch")
	TEST_ASSERT_EQUAL(ftl.anchored_to, host, "Launching from the home port didn't restore the FTL tether")
	var/obj/item/fighter_component/docking_computer/DC = sabre.loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	TEST_ASSERT(DC?.docking_mode, "The launched Sabre doesn't have docking mode on")
	DC.docking_cooldown = FALSE
	TEST_ASSERT(!sabre.docking_act(host), "The Sabre docked back into the ship it just left")

	// Bez uwiązu „Powrót” bierze okręt portu domowego
	ftl.anchored_to = null
	sabre.can_return_jump(pilot)
	TEST_ASSERT_EQUAL(ftl.anchored_to, host, "A return jump without a tether didn't fall back to the home port's ship")

	// Lądowanie wyłącza alarm, którego po przepisaniu ludzi do gospodarza nic by już nie zatrzymało
	sabre.set_master_caution(TRUE)
	TEST_ASSERT(sabre.master_caution, "The master caution didn't turn on")
	ftl.anchored_to = null
	TEST_ASSERT(sabre.shuttle_land(host, port), "The Sabre didn't land at its home port")
	TEST_ASSERT(!sabre.master_caution, "The master caution kept looping after landing")
	TEST_ASSERT_EQUAL(ftl.anchored_to, host, "Landing at the home port didn't refresh the FTL tether")

	// Ręcznie wybrane miejsce obrócone na wschód: wnętrze staje dokładnie w obrysie, który pokazywała kamera
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch again")

	// Ktoś siada za sterem w trakcie wyboru miejsca lądowania: kamera i timer znikają, prom nie ląduje przy starym celu
	var/mob/camera/ai_eye/remote/shuttle_craft_landing/eye = new(get_turf(port))
	eye.craft = sabre
	eye.landing_target = host
	sabre.shuttle_landing_eye = eye
	sabre.shuttle_landing_timer = addtimer(CALLBACK(sabre, TYPE_PROC_REF(/obj/structure/overmap/small_craft/transport, shuttle_manual_landing_timeout), eye), 60 SECONDS, TIMER_STOPPABLE)
	DC.docking_cooldown = TRUE
	var/mob/living/carbon/human/new_pilot = allocate(/mob/living/carbon/human)
	sabre.start_piloting(new_pilot, OVERMAP_USER_ROLE_PILOT)
	TEST_ASSERT(!sabre.shuttle_landing_eye && QDELETED(eye), "Taking the helm didn't close the landing camera")
	TEST_ASSERT(!sabre.shuttle_landing_timer, "Taking the helm left the landing timeout running")
	TEST_ASSERT(!sabre.shuttle_docked_at, "Taking the helm during the landing choice landed the Sabre")
	TEST_ASSERT(!DC.docking_cooldown, "Taking the helm left the docking computer locked")
	sabre.stop_piloting(new_pilot)
	var/turf/spot = locate(bl[1] + 20, bl[2] + 20, bl[3])
	var/list/rotated = sabre.shuttle_rotate_offsets(sabre.hull_offsets, EAST)
	TEST_ASSERT_EQUAL(length(rotated), length(sabre.hull_offsets), "Rotating the hull outline lost tiles")
	TEST_ASSERT(sabre.shuttle_spot_free(host, spot.x, spot.y, spot.z, rotated), "The empty hangar spot isn't free for the rotated hull")
	TEST_ASSERT(sabre.shuttle_land_at_spot(host, spot, EAST), "The Sabre didn't land at the chosen spot")
	TEST_ASSERT_EQUAL(shuttle_port.dir, EAST, "The interior didn't turn to the chosen direction")
	for(var/list/offset as anything in rotated)
		var/turf/T = locate(spot.x + offset[1], spot.y + offset[2], spot.z)
		TEST_ASSERT(istype(T?.loc, /area/shuttle/sabre), "The landed hull doesn't cover the previewed tile [offset[1]],[offset[2]]")
	var/obj/docking_port/stationary/landed_spot = sabre.shuttle_docked_at

	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	if(landed_spot && !QDELETED(landed_spot))
		qdel(landed_spot, TRUE)
	qdel(port, TRUE)
	qdel(hangar)

/// AQUILA - strzelec lasera obrony punktowej (Von Neumann) i wieżyczki przeciwlotniczej dostaje przycisk wyjścia z kamery,
/// a stanowisko po wyjściu nie trzyma go jako strzelca
/datum/unit_test/point_defense_gunner_exit

/datum/unit_test/point_defense_gunner_exit/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host, "No main ship")
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human)
	TEST_ASSERT(host.gives_observer_off_action(gunner), "An ordinary observer gets no exit button")
	// Nie LAZYREMOVE: pusta lista zmieniłaby się w null, a 50Cal.dm robi gauss_gunners.Add() bez sprawdzania
	host.gauss_gunners += gunner
	var/allowed = host.gives_observer_off_action(gunner)
	host.gauss_gunners -= gunner
	TEST_ASSERT(allowed, "A point defense gunner outside a gauss gun gets no exit button")

	var/obj/machinery/ship_weapon/energy/laser_pd/laser = allocate(/obj/machinery/ship_weapon/energy/laser_pd)
	laser.gunner = gunner
	laser.remove_gunner()
	TEST_ASSERT(isnull(laser.gunner), "The laser keeps its old gunner after removing it")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
