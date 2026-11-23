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
	for(var/obj/effect/overlay/planet_sky_part/part as anything in sky.descent_parts())
		TEST_ASSERT(part in sky.vis_contents, "A part of the descent transitions (sky, haze, cloud, mist, heat, streaks) is missing")
		// Nad terenem pod promem, nie na paralaksie: inaczej teren zasłoniłby niebo i chmurę
		TEST_ASSERT_EQUAL(part.plane, AQ_LANDING_VIEW_PLANE, "A part of the descent transitions isn't drawn over the ground under the shuttle")
	// Biały BYOND zapisuje jako brak koloru (null)
	TEST_ASSERT_EQUAL(sky.cloud_fill.color || "#ffffff", jungle.sky_cloud_color || "#ffffff", "The inside of the cloud isn't the planet's cloud colour")
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

	// Przerwane zejście blednie i kończy się z opóźnieniem; nowe zejście zaraz potem anuluje ten koniec, inaczej spóźniony
	// koniec zabrałby planetę z nowego pokazu
	sky.play_descent(jungle)
	sky.end_descent(fade = TRUE)
	TEST_ASSERT(sky.end_timer, "An aborted descent didn't schedule the end of its fade-out")
	sky.play_descent(jungle)
	TEST_ASSERT(!sky.end_timer, "A new descent kept the delayed end of the aborted one: it would cut the new show short")
	TEST_ASSERT(sky.descent_active, "The new descent show didn't start after an aborted one")
	sky.end_descent()
	qdel(sky)

	// Nakładki kopii pól w obrazie terenu: z płaszczyzny podłogi i gry przechodzą na płaszczyznę obrazu (inaczej rysowałyby
	// się poza nim, bez maski), z innych płaszczyzn odpadają
	var/mutable_appearance/on_game = mutable_appearance('aquila/icons/effects/planet_descent.dmi', "fill", plane = GAME_PLANE)
	var/mutable_appearance/on_light = mutable_appearance('aquila/icons/effects/planet_descent.dmi', "fill", plane = LIGHTING_PLANE)
	var/list/kept = planet_ground_world_layers(list(on_game, on_light))
	TEST_ASSERT_EQUAL(length(kept), 1, "A ground picture part kept an overlay from a plane outside the world")
	var/mutable_appearance/kept_layer = kept[1]
	TEST_ASSERT_EQUAL(kept_layer.plane, FLOAT_PLANE, "A ground picture part kept an overlay on its own world plane, outside the picture's mask")

/// AQUILA - Sabre na planecie nie dokuje od razu: schodzi, a dokuje dopiero na końcu zejścia. Zejście przerwane, bo prom
/// nie jest już nad planetą, kończy się bez lądowania i z wolnym komputerem dokowania
/datum/unit_test/planet_descent_landing
	/// Planeta testu (zwykłe qdel jej nie usuwa): Destroy usuwa ją z force także po nieudanej asercji
	var/obj/structure/overmap/planet/test_planet

/datum/unit_test/planet_descent_landing/Destroy()
	if(test_planet && !QDELETED(test_planet))
		test_planet.surface?.unload()
		qdel(test_planet, TRUE)
	test_planet = null
	return ..()

/datum/unit_test/planet_descent_landing/Run()
	// Parking w locie: pełny zapas dla zwykłego promu, mniejszy dla bardzo dużego, a za duży prom w ogóle nie rezerwuje
	// (każda próba dodawałaby nowy poziom rezerwacji)
	var/usable = min(world.maxx, world.maxy) - 2 * SHUTTLE_TRANSIT_BORDER + 1
	TEST_ASSERT(shuttle_parking_margin(9, 9) >= 10, "A Sabre-sized shuttle doesn't get the full empty parking margin")
	var/big_margin = shuttle_parking_margin(usable - 6, 9)
	TEST_ASSERT(big_margin >= 1 && usable - 6 + 2 * big_margin <= usable, "A very big shuttle's parking doesn't fit on a reserved level")
	TEST_ASSERT_EQUAL(shuttle_parking_margin(usable, 9), -1, "A shuttle bigger than a reserved level still asks for a parking reservation")
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
	// Z kokpitu widać, co jest wokół promu: żadna ściana Sabre nie zasłania widoku, a szyby mają swoją nazwę
	var/windows = 0
	for(var/turf/closed/wall in shuttle_port.return_turfs())
		TEST_ASSERT(!wall.opacity, "A Sabre hull wall [wall.type] blocks the view")
		if(istype(wall, /turf/closed/indestructible/dropship/sabre_window))
			windows++
	TEST_ASSERT_EQUAL(windows, 7, "The Sabre cockpit should have seven windows")
	// Przezroczyste brzegi wycinków kadłuba (zaokrąglony przód) pokazują to, na czym stoi prom, a nie czarne pole
	sleep(2)
	TEST_ASSERT(planet_test_hull_front_underlaid(shuttle_port), "The see-through front of the Sabre hull shows nothing under it in the hangar")
	sabre.set_fuel(500)
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't launch")
	// W locie wokół kadłuba jest tylko własny kosmos parkingu: z promu nie widać skał sąsiedniej rezerwacji
	var/datum/turf_reservation/parking = sabre.shuttle_parking_reservation
	for(var/turf/hull_turf as anything in shuttle_port.return_turfs())
		for(var/dir in GLOB.alldirs)
			var/turf/far = get_ranged_target_turf(hull_turf, dir, 10)
			TEST_ASSERT(SSmapping.used_turfs[far] == parking, "The parking around the Sabre ends closer than 10 tiles from its hull ([COORD(far)])")

	var/obj/structure/overmap/planet/planet = host.current_system.add_planet(/datum/planet_type/lava, clamp(host.x + 20, 30, world.maxx - 40), clamp(host.y, 30, world.maxy - 40))
	test_planet = planet
	// Mniejsza niż karłowata powierzchnia (jedno lądowisko wystarczy): generowanie lawowej trwało w CI ponad 20 s
	planet.planet_type.surface_size = 47
	planet.surface.skip_ruins = TRUE
	TEST_ASSERT(planet.surface.generate(), "The planet surface didn't generate")
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
	var/datum/planet_descent/descent = sabre.planet_descent
	TEST_ASSERT(descent.shadow, "No hull shadow over the ground during the approach")
	TEST_ASSERT_EQUAL(length(descent.berth), length(descent.hull_order), "The hull and the landing spot don't pair up tile for tile")
	TEST_ASSERT_EQUAL(length(descent.berth), length(sabre.planet_landing_footprint(port)), "The landing spot of the ground view isn't the hull footprint")
	// Ostatnia faza: pod promem prawdziwy teren lądowiska, środek w środek tak, jak stanie kadłub, przycięty maską do pól
	// kosmosu wokół kadłuba
	var/datum/planet_ground_view/ground = descent.ground_view
	TEST_ASSERT(ground, "No real ground under the shuttle in the last phase of the descent")
	TEST_ASSERT(length(ground.close_picture.overlays), "The close-up picture of the landing site is empty")
	if(!descent.rotation)
		TEST_ASSERT(ground.ground_x - port.x == ground.hull_x - shuttle_port.x && ground.ground_y - port.y == ground.hull_y - shuttle_port.y, "The ground picture isn't centred where the hull will stand")
	TEST_ASSERT(length(ground.masked_turfs), "The ground picture has no mask: nothing of it would be seen")
	// Maska obejmuje też kadłub: przez przezroczyste brzegi jego wycinków widać teren pod promem
	var/turf/hull_first = shuttle_hull_turfs(shuttle_port)[1]
	TEST_ASSERT(hull_first in ground.masked_turfs, "The ground picture's mask leaves out the hull: its see-through edges would show space")
	// Obraz z daleka (rust-g; w zejściu piecze się w tle, tu mały wycinek, żeby test nie czekał): 2 piksele na pole
	var/icon/aerial = planet_ground_aerial(port.x, port.y, port.z, 4, 2, null, planet.surface.reservation)
	TEST_ASSERT(aerial && aerial.Width() == 16 && aerial.Height() == 16, "No picture of the ground from afar")
	// Z ziemi: cień na lądowisku, spadający obraz promu i kurz od dysz
	descent.show_ground_shadow()
	descent.show_ground_proxy()
	descent.thruster_wash()
	TEST_ASSERT(descent.ground_shadow, "No hull shadow on the landing site")
	TEST_ASSERT(descent.ground_shadow.z == port.z, "The hull shadow isn't on the planet")
	var/obj/effect/abstract/planet_landing_proxy/falling = descent.ground_proxy
	TEST_ASSERT(falling && length(falling.overlays), "No picture of the shuttle falling onto the landing site")
	TEST_ASSERT(falling.z == port.z, "The falling shuttle isn't over the planet")
	descent.finish()
	TEST_ASSERT(!sabre.planet_descent, "The descent didn't end after touchdown")
	TEST_ASSERT(QDELETED(falling), "The picture of the falling shuttle stayed over the landed hull")
	TEST_ASSERT(QDELETED(ground), "The ground picture stayed in the flight parking after touchdown")
	// Kadłub Sabre nie zasłania widoku także po dokowaniu na planecie (dokowanie kopiuje pola)
	for(var/turf/closed/wall in shuttle_port.return_turfs())
		TEST_ASSERT(!wall.opacity, "A Sabre hull wall [wall.type] blocks the view after landing on the planet")
	TEST_ASSERT_EQUAL(shuttle_port.docked, port, "The interior isn't on the landing spot after the descent.")
	TEST_ASSERT_EQUAL(sabre.shuttle_docked_at, port, "The Sabre doesn't count as landed after the descent")
	TEST_ASSERT(planet_test_hull_front_underlaid(shuttle_port), "The see-through front of the Sabre hull shows nothing under it on the planet")
	// Kratka silnika nie prześwituje: po przelocie ma tło w kolorze blach kadłuba, a nie zrzut gruntu spod promu
	TEST_ASSERT(planet_test_engine_filled(shuttle_port), "The Sabre engine grille shows the ground through it after landing instead of the hull colour")
	for(var/turf/T as anything in shuttle_hull_turfs(shuttle_port))
		TEST_ASSERT(!(locate(/obj/effect/planet_landing_blocker) in T), "A landing blocker stayed under the hull after touchdown")

	// Start z planety i drugie zejście, przerwane: prom odleciał znad planety, zanim zszedł. Z ziemi obraz promu odlatuje
	// z miejsca, w którym stał
	var/turf/site_center = planet_landing_center(shuttle_hull_turfs(shuttle_port))
	TEST_ASSERT(sabre.shuttle_launch(), "The Sabre didn't take off from the planet")
	var/obj/effect/abstract/planet_landing_proxy/leaving = locate() in site_center
	TEST_ASSERT(leaving && length(leaving.overlays), "No picture of the shuttle leaving the landing site")
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

	// Trzecie zejście: obrys lądowiska jest zajęty dla innych promów, a coś postawione na nim w trakcie zejścia przerywa
	// lądowanie (dokowanie zabiłoby ludzi i usunęło przedmioty pod kadłubem)
	DC.docking_mode = TRUE
	DC.docking_cooldown = FALSE
	var/obj/docking_port/stationary/third_port = sabre.shuttle_find_landing(planet)
	TEST_ASSERT(third_port, "No landing spot for the third descent")
	TEST_ASSERT(sabre.shuttle_land(planet, third_port), "The third descent didn't start")
	var/list/footprint = sabre.planet_landing_footprint(third_port)
	TEST_ASSERT(length(footprint), "The landing spot has no hull footprint")
	var/turf/blocked = footprint[1]
	TEST_ASSERT(planet_descent_reserved(blocked, null), "Another shuttle could land on the spot of a descending shuttle")
	TEST_ASSERT(!planet_descent_reserved(blocked, sabre), "A descending shuttle blocks its own landing spot")
	var/obj/structure/girder/obstacle = new(blocked)
	sabre.planet_descent.finish()
	TEST_ASSERT(!sabre.shuttle_docked_at, "The Sabre landed on an occupied spot")
	TEST_ASSERT(QDELETED(third_port), "The blocked landing spot stayed on the planet")
	TEST_ASSERT(!QDELETED(obstacle), "Landing on an occupied spot deleted what stood there")
	TEST_ASSERT(!planet_descent_reserved(blocked, null), "The landing spot stayed reserved after the aborted descent")
	qdel(obstacle)

	// Leżący człowiek (density FALSE) też blokuje lądowisko: dokowanie by go zabiło
	var/obj/docking_port/stationary/fourth_port = sabre.shuttle_find_landing(planet)
	TEST_ASSERT(fourth_port, "No landing spot for the lying mob check")
	var/list/fourth_footprint = sabre.planet_landing_footprint(fourth_port)
	var/mob/living/carbon/human/lying = allocate(/mob/living/carbon/human, fourth_footprint[1])
	lying.density = FALSE
	TEST_ASSERT(!sabre.planet_landing_spot_free(planet, fourth_port), "A lying person doesn't block the landing spot")
	qdel(lying)
	TEST_ASSERT(sabre.planet_landing_spot_free(planet, fourth_port), "The landing spot stays blocked after the person left")
	// Blokada lądowiska trzyma przez całe dokowanie: toShuttleMove() (preflight_check, pole po polu) jej nie usuwa,
	// a nikt nie wejdzie na zablokowane pole w czasie CHECK_TICK przed przeniesieniem kadłuba
	// Pole obrysu na krawędzi, obok którego da się stanąć (powierzchnia jest losowa, więc szukamy po całym obrysie)
	var/turf/probe
	var/turf/beside
	for(var/turf/edge as anything in fourth_footprint)
		for(var/dir in GLOB.cardinals)
			var/turf/T = get_step(edge, dir)
			if(T && !(T in fourth_footprint) && sabre.shuttle_landing_turf_free(planet, T))
				probe = edge
				beside = T
				break
		if(beside)
			break
	TEST_ASSERT(beside, "No free tile next to the landing spot")
	var/obj/effect/planet_landing_blocker/blocker = new(probe)
	probe.toShuttleMove(shuttle_hull_turfs(shuttle_port)[1], MOVE_TURF, shuttle_port)
	TEST_ASSERT(!QDELETED(blocker), "The docking deleted a landing blocker before the hull arrived")
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, beside)
	walker.Move(probe, get_dir(beside, probe))
	TEST_ASSERT(get_turf(walker) != probe, "Someone walked onto a blocked landing tile during docking")
	qdel(blocker)
	qdel(fourth_port, TRUE)

	// Kurz przy przyziemieniu: w kolorze chmur planety, gdy typ go ustawia (wulkaniczna: popiół), inaczej piaskowy
	var/turf/dust_turf = planet.surface.landing_zones[1]
	planet_touchdown_effects(null, planet, list(dust_turf))
	var/obj/effect/temp_visual/planet_landing_dust/dust = locate() in dust_turf
	TEST_ASSERT(dust, "No dust at touchdown")
	TEST_ASSERT_EQUAL(dust.color, planet.planet_type.sky_cloud_color, "Touchdown dust doesn't take the planet's ash colour")
	var/datum/planet_type/lava_type = planet.planet_type
	var/old_cloud_color = lava_type.sky_cloud_color
	lava_type.sky_cloud_color = "#ffffff"
	qdel(dust)
	planet_touchdown_effects(null, planet, list(dust_turf))
	dust = null
	for(var/obj/effect/temp_visual/planet_landing_dust/fresh in dust_turf)
		if(!QDELETED(fresh))
			dust = fresh
	lava_type.sky_cloud_color = old_cloud_color
	TEST_ASSERT_EQUAL(dust?.color, "#c8b890", "Touchdown dust on a planet with plain white clouds isn't sandy")
	qdel(dust)

	TEST_ASSERT(sabre.shuttle_land(host, home), "The Sabre didn't land back home")
	shuttle_port.jumpToNullSpace()
	if(!QDELETED(sabre))
		qdel(sabre)
	qdel(home, TRUE)
	qdel(hangar)

/// Czy każda kratka silnika Sabre ma jedno tło w kolorze blach kadłuba
/proc/planet_test_engine_filled(obj/docking_port/mobile/shuttle_port)
	var/found = 0
	for(var/turf/closed/indestructible/dropship/hull in shuttle_port.return_turfs())
		if(hull.see_through_edges())
			continue
		found++
		if(length(hull.underlays) != 1)
			return FALSE
		var/mutable_appearance/inside = hull.underlays[1]
		if(inside.color != "#2c3539")
			return FALSE
	return found > 0

/// Czy wycinek przodu kadłuba Sabre (z przezroczystymi pikselami) ma pod sobą podkład z gruntem
/proc/planet_test_hull_front_underlaid(obj/docking_port/mobile/shuttle_port)
	for(var/turf/closed/indestructible/dropship/hull in shuttle_port.return_turfs())
		if(hull.icon_state == "blue_front")
			return length(hull.underlays) > 0
	return FALSE

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
