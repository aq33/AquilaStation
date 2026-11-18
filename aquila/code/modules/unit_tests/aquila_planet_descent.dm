// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - zejście na planetę na warstwie nieba: pokaz zejścia i startu dokłada niebo, smugi i chmury, w trakcie
/// nie przestawia planety, a po końcu wszystko wraca do zwykłej planety za oknami
/datum/unit_test/planet_descent_layer

/datum/unit_test/planet_descent_layer/Run()
	var/datum/planet_type/jungle = GLOB.planet_type_prototypes[/datum/planet_type/jungle]
	var/datum/planet_type/moon = GLOB.planet_type_prototypes[/datum/planet_type/moon]
	var/atom/movable/screen/parallax_layer/planet_sky/sky = new(null, world.view)
	sky.play_descent(jungle)
	TEST_ASSERT(sky.descent_active, "The descent show didn't start")
	TEST_ASSERT_EQUAL(sky.shown_type, jungle, "The descent doesn't show the planet it lands on")
	TEST_ASSERT(sky.sky_fill in sky.vis_contents, "No atmosphere sky during the descent")
	TEST_ASSERT_EQUAL(sky.sky_fill.color, jungle.sky_atmosphere_color, "The descent sky isn't the planet's atmosphere colour")
	for(var/obj/effect/overlay/planet_sky_part/part as anything in sky.streak_parts + sky.rush_parts)
		TEST_ASSERT(part in sky.vis_contents, "A streak or cloud part is missing from the descent")
	var/obj/effect/overlay/planet_sky_part/rush = sky.rush_parts[1]
	TEST_ASSERT_EQUAL(rush.icon_state, jungle.sky_clouds, "The clouds rushing past aren't the planet's clouds")
	// W trakcie pokazu zwykłe sprawdzanie planety (bez okrętu: null) nie może jej schować
	sky.update_status(null)
	TEST_ASSERT_EQUAL(sky.shown_type, jungle, "A parallax update hid the planet in the middle of the descent")
	sky.end_descent()
	TEST_ASSERT(!sky.descent_active, "The descent show didn't end")
	TEST_ASSERT(!(sky.sky_fill in sky.vis_contents), "The descent sky stayed after landing")
	TEST_ASSERT_EQUAL(length(sky.vis_contents), 0, "The planet stayed in the sky after landing")
	TEST_ASSERT_EQUAL(sky.body.alpha, 255, "The planet disk stayed faded after the descent")

	sky.play_ascent(moon)
	TEST_ASSERT(sky.descent_active, "The take-off show didn't start")
	TEST_ASSERT_EQUAL(sky.shown_type, moon, "The take-off doesn't show the planet the shuttle leaves")
	sky.end_descent()
	TEST_ASSERT(!sky.descent_active, "The take-off show didn't end")
	qdel(sky)

/// AQUILA - Sabre na planecie nie dokuje od razu: schodzi, a dokuje dopiero na końcu zejścia. Zejście przerwane, bo prom
/// nie jest już nad planetą, kończy się bez lądowania i z wolnym komputerem dokowania
/datum/unit_test/planet_descent_landing

/datum/unit_test/planet_descent_landing/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system?.occupying_z, "No main ship in a loaded star system")
	var/datum/turf_reservation/hangar = SSmapping.RequestBlockReservation(30, 30)
	hangar.overmap_fallback = host
	var/list/bl = hangar.bottom_left_coords
	var/obj/docking_port/stationary/sabre/mining/home = new(locate(bl[1] + 15, bl[2] + 20, bl[3]))
	var/timeout = world.time + 30 SECONDS
	while(!home.docked && world.time < timeout)
		sleep(1)
	var/obj/docking_port/mobile/sabre/shuttle_port = home.docked
	TEST_ASSERT(istype(shuttle_port), "The Sabre template didn't dock at its port")
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre = shuttle_port.craft
	// Z kokpitu widać zejście przez szyby: przednią, boczne w narożnikach i dwa okna w burtach
	var/windows = 0
	for(var/turf/closed/indestructible/dropship/sabre_window/window in shuttle_port.return_turfs())
		TEST_ASSERT(!window.opacity, "A Sabre cockpit window blocks the view")
		windows++
	TEST_ASSERT_EQUAL(windows, 7, "The Sabre cockpit should have seven windows")
	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch")

	var/obj/structure/overmap/planet/planet = host.current_system.add_planet(/datum/planet_type/lava, clamp(host.x + 20, 30, world.maxx - 40), clamp(host.y, 30, world.maxy - 40))
	TEST_ASSERT(planet_test_fast_surface(planet), "The planet surface didn't generate")
	sabre.forceMove(planet.center_turf())
	// Szukanie miejsca usypia (CHECK_TICK): prom z prędkością ze startu odleciałby w tym czasie znad planety
	sabre.velocity._set(0, 0)
	sabre.brakes = TRUE
	TEST_ASSERT(planet.craft_over_planet(sabre), "The Sabre isn't over the planet in docking mode")
	sabre.planet_landing_zone = planet.surface.landing_zones[1]
	var/obj/docking_port/stationary/port = sabre.shuttle_find_landing(planet)
	TEST_ASSERT(port, "No landing spot on the planet")

	TEST_ASSERT(sabre.shuttle_land(planet, port), "Landing on the planet didn't start")
	TEST_ASSERT(sabre.planet_descent, "The Sabre docked at once instead of descending")
	TEST_ASSERT_EQUAL(shuttle_port.docked, sabre.shuttle_parking, "The interior left its parking spot before the descent ended")
	TEST_ASSERT(!sabre.can_move(), "The Sabre can be flown during the descent")
	TEST_ASSERT(!sabre.shuttle_land(planet, port), "A second landing started in the middle of the descent")
	TEST_ASSERT(!QDELETED(port), "A second landing call deleted the landing spot of the descent")
	// Fazy pokazu bez klientów: żar przy kadłubie, iskry i lampy w kabinie nie mogą się wysypać
	sabre.planet_descent.reentry()
	sabre.planet_descent.clouds()
	sabre.planet_descent.approach()
	TEST_ASSERT(sabre.planet_descent.shadow, "No hull shadow over the ground during the approach")
	sabre.planet_descent.finish()
	TEST_ASSERT(!sabre.planet_descent, "The descent didn't end after touchdown")
	TEST_ASSERT_EQUAL(shuttle_port.docked, port, "The interior isn't on the landing spot after the descent.")
	TEST_ASSERT_EQUAL(sabre.shuttle_docked_at, port, "The Sabre doesn't count as landed after the descent")

	// Start z planety i drugie zejście, przerwane: prom odleciał znad planety, zanim zszedł
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't take off from the planet")
	sabre.forceMove(planet.center_turf())
	// Szukanie miejsca usypia (CHECK_TICK): prom z prędkością ze startu odleciałby w tym czasie znad planety
	sabre.velocity._set(0, 0)
	sabre.brakes = TRUE
	var/obj/item/fighter_component/docking_computer/DC = sabre.loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	DC.docking_mode = TRUE
	var/obj/docking_port/stationary/second_port = sabre.shuttle_find_landing(planet)
	TEST_ASSERT(second_port, "No landing spot for the second descent")
	TEST_ASSERT(sabre.shuttle_land(planet, second_port), "The second descent didn't start")
	DC.docking_cooldown = TRUE
	DC.docking_mode = FALSE
	sabre.planet_descent.finish()
	TEST_ASSERT(!sabre.shuttle_docked_at, "The Sabre landed although it left docking mode during the descent")
	TEST_ASSERT_EQUAL(shuttle_port.docked, sabre.shuttle_parking, "The interior didn't stay parked after the aborted descent")
	TEST_ASSERT(QDELETED(second_port), "The unused landing spot stayed on the planet")
	TEST_ASSERT(!DC.docking_cooldown, "The docking computer stayed locked after the aborted descent")

	TEST_ASSERT(sabre.shuttle_land(host, home), "The Sabre didn't land back home")
	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(home, TRUE)
	qdel(hangar)
	planet.surface.unload()
	qdel(planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
