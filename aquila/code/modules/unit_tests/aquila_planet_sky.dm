// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planeta na niebie: każdy typ planety widoczny z okrętu ma swoje tekstury w plikach generatora
/datum/unit_test/planet_sky_states

/datum/unit_test/planet_sky_states/Run()
	var/list/surface_states = icon_states('aquila/icons/effects/planet_sky_surface.dmi')
	var/list/disk_states = icon_states('aquila/icons/effects/planet_sky_disk.dmi')
	for(var/state in list("base", "displace", "mask", "shade", "atmosphere"))
		TEST_ASSERT(state in disk_states, "planet_sky_disk.dmi has no state [state]")
	var/shown = 0
	for(var/planet_type in GLOB.planet_type_prototypes)
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		if(!prototype.sky_state)
			continue
		shown++
		TEST_ASSERT(prototype.sky_state in surface_states, "[planet_type] has sky_state [prototype.sky_state] missing from planet_sky_surface.dmi")
		if(prototype.sky_clouds)
			TEST_ASSERT(prototype.sky_clouds in surface_states, "[planet_type] has sky_clouds [prototype.sky_clouds] missing from planet_sky_surface.dmi")
		TEST_ASSERT(prototype.sky_scale > 0, "[planet_type] has no sky_scale")
	TEST_ASSERT(shown > 0, "No planet type is visible in the sky")
	TEST_ASSERT(!GLOB.planet_type_prototypes[/datum/planet_type/asteroid]?.sky_state, "An asteroid field shouldn't show up as a planet in the sky")

/// AQUILA - planeta na niebie: wybór najbliższej planety i składanie obrazu (tarcza z filtrami, chmury, poświata)
/datum/unit_test/planet_sky_layer
	/// Planety testu: zwykłe qdel ich nie usuwa (QDEL_HINT_LETMELIVE), więc Destroy usuwa je z force także po nieudanej asercji
	var/list/planets = list()
	var/atom/movable/screen/parallax_layer/planet_sky/sky

/datum/unit_test/planet_sky_layer/Destroy()
	for(var/obj/structure/overmap/planet/planet as anything in planets)
		if(!QDELETED(planet))
			qdel(planet, TRUE)
	planets.Cut()
	QDEL_NULL(sky)
	return ..()

/datum/unit_test/planet_sky_layer/Run()
	var/turf/viewer = run_loc_floor_bottom_left
	var/obj/structure/overmap/planet/hidden = new(viewer, /datum/planet_type/asteroid)
	var/obj/structure/overmap/planet/near = new(locate(viewer.x + 1, viewer.y + 1, viewer.z), /datum/planet_type/moon)
	var/obj/structure/overmap/planet/far = new(run_loc_floor_top_right, /datum/planet_type/lava)
	planets = list(far, hidden, near)
	TEST_ASSERT_EQUAL(pick_sky_planet(planets, viewer), near, "The nearest planet visible in the sky wasn't picked")
	TEST_ASSERT_EQUAL(pick_sky_planet(list(far, hidden), viewer), far, "An asteroid field was picked instead of a planet")
	TEST_ASSERT_EQUAL(pick_sky_planet(list(hidden), viewer), null, "An asteroid field showed up in the sky")

	sky = new(null, world.view)
	sky.show_planet(far.planet_type)
	TEST_ASSERT(sky.body in sky.vis_contents, "The planet disk isn't shown")
	TEST_ASSERT(sky.shade in sky.vis_contents, "The planet shadow isn't shown")
	TEST_ASSERT(sky.atmosphere in sky.vis_contents, "A planet with an atmosphere has no glow")
	TEST_ASSERT_EQUAL(length(sky.body.filters), 2, "The disk should bend the texture (displace) and cut it to a circle (alpha)")
	TEST_ASSERT_EQUAL(length(sky.body.vis_contents), 2, "A planet with clouds should have a surface and a cloud texture")
	var/obj/effect/overlay/planet_sky_part/strip = sky.surface_strips[1]
	TEST_ASSERT_EQUAL(strip.icon_state, far.planet_type.sky_state, "The surface strip doesn't show the planet type")
	TEST_ASSERT_EQUAL(sky.body.transform.a, far.planet_type.sky_scale, "The disk isn't scaled for the planet type")

	sky.show_planet(near.planet_type)
	TEST_ASSERT(!(sky.atmosphere in sky.vis_contents), "A moon without an atmosphere still glows")
	TEST_ASSERT_EQUAL(length(sky.body.vis_contents), 1, "A planet without clouds still shows clouds")
	TEST_ASSERT_EQUAL(sky.body.transform.a, near.planet_type.sky_scale, "The disk wasn't rescaled for the new planet")

	sky.show_planet(null)
	TEST_ASSERT_EQUAL(length(sky.vis_contents), 0, "The sky still shows a planet")


/// AQUILA - planeta na niebie: odświeżenie z timera wybiera planetę od nowa, nawet gdy zapamiętany wybór jest jeszcze
/// ważny (timer nie trafia w next_check, więc niebo pokazywało starą planetę o jeden okres dłużej)
/datum/unit_test/planet_sky_recheck
	var/obj/structure/overmap/planet/test_planet
	var/atom/movable/screen/parallax_layer/planet_sky/sky

/datum/unit_test/planet_sky_recheck/Destroy()
	if(test_planet && !QDELETED(test_planet))
		qdel(test_planet, TRUE)
	test_planet = null
	QDEL_NULL(sky)
	return ..()

/datum/unit_test/planet_sky_recheck/Run()
	var/obj/structure/overmap/host = SSstar_system.find_main_overmap()
	TEST_ASSERT(host?.current_system?.occupying_z, "No main ship in a loaded star system")
	// Poziom testowy nie należy do okrętu: pasażer stoi na pierwszym poziomie okrętu (wystarczy do get_overmap)
	var/list/ship_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	TEST_ASSERT(length(ship_levels), "No main ship level")
	var/mob/living/carbon/human/passenger = allocate(/mob/living/carbon/human, locate(round(world.maxx / 2), round(world.maxy / 2), ship_levels[1]))
	TEST_ASSERT_EQUAL(passenger.get_overmap(), host, "The test passenger isn't aboard the main ship")
	// Nowa planeta tuż przy okręcie: najbliższa ze wszystkich w układzie
	test_planet = host.current_system.add_planet(/datum/planet_type/jungle, host.x, host.y)
	var/datum/planet_type/stale = GLOB.planet_type_prototypes[/datum/planet_type/moon]
	sky = new(null, world.view)
	sky.checked_system = host.current_system
	sky.checked_type = stale
	sky.next_check = world.time + 1 HOURS
	sky.update_status(passenger)
	TEST_ASSERT_EQUAL(sky.shown_type, stale, "A parallax update inside the recheck delay should keep the remembered planet")
	sky.force_recheck(passenger)
	TEST_ASSERT_EQUAL(sky.shown_type, test_planet.planet_type, "The timed recheck kept the stale planet instead of picking the nearest one")
	// Bez klienta pętla odświeżania się kończy i puszcza postać (warstwy paralaksy zostają po wyjściu gracza)
	var/first_timer = sky.recheck_timer
	TEST_ASSERT(first_timer, "A parallax update didn't start the sky recheck loop")
	sky.recheck_sky()
	TEST_ASSERT(!sky.recheck_timer, "The sky recheck loop kept running without a client")
	TEST_ASSERT(!SStimer.timer_id_dict[first_timer], "The stopped sky recheck timer is still scheduled")
	TEST_ASSERT(!sky.current_mob, "The sky layer kept a reference to the mob without a client")
	// Paralaksa włączona z powrotem (create_parallax woła force_recheck): pętla odświeżania rusza bez ruchu gracza
	sky.force_recheck(passenger)
	TEST_ASSERT(sky.recheck_timer, "The sky recheck loop didn't resume when the layer came back")

/// AQUILA - planeta na niebie: po zmianie widoku warstwa z planetą zostaje podmieniona na nową. Stara warstwa trzymała
/// granice obrazu planety ze starego widoku i mapa rysowała się o kolumnę szersza (pas za HUD-em bez światła).
/datum/unit_test/planet_sky_view_change
	var/atom/movable/screen/parallax_layer/planet_sky/sky
	var/atom/movable/screen/parallax_layer/planet_sky/fresh

/datum/unit_test/planet_sky_view_change/Destroy()
	QDEL_NULL(sky)
	QDEL_NULL(fresh)
	return ..()

/datum/unit_test/planet_sky_view_change/Run()
	var/datum/planet_type/shown = GLOB.planet_type_prototypes[/datum/planet_type/lava]
	var/atom/movable/screen/parallax_layer/layer_1/other = allocate(/atom/movable/screen/parallax_layer/layer_1, null, "17x15")
	sky = new(null, "17x15")
	sky.show_planet(shown)
	sky.screen_loc = "CENTER-7:-6,CENTER-7:3"
	var/list/cached = list(other, sky)
	var/list/active = list(other, sky)
	var/list/client_screen = list(sky)
	fresh = sky.replace_in(cached, active, client_screen, "15x15")
	TEST_ASSERT(fresh && fresh != sky, "No new sky layer was made")
	TEST_ASSERT_EQUAL(cached[2], fresh, "The cached parallax layers still hold the old sky layer")
	TEST_ASSERT_EQUAL(active[2], fresh, "The active parallax layers still hold the old sky layer")
	TEST_ASSERT_EQUAL(cached[1], other, "Another parallax layer was replaced")
	TEST_ASSERT((fresh in client_screen) && !(sky in client_screen), "The client screen still shows the old sky layer")
	TEST_ASSERT_EQUAL(fresh.shown_type, shown, "The new sky layer doesn't show the same planet")
	TEST_ASSERT(fresh.body in fresh.vis_contents, "The new sky layer has no planet disk")
	TEST_ASSERT_EQUAL(fresh.screen_loc, sky.screen_loc, "The new sky layer jumped to another parallax offset")
	TEST_ASSERT_EQUAL(fresh.view_sized, "15x15", "The new sky layer wasn't made for the new view")
	// Bez parallax_layers (paralaksa wyłączona) podmiana zostaje w cache'u
	var/atom/movable/screen/parallax_layer/planet_sky/second = fresh.replace_in(cached, null, null, "17x15")
	TEST_ASSERT_EQUAL(cached[2], second, "The cached sky layer wasn't replaced with parallax off")
	// Stara warstwa zniknęła z ekranu przy zmianie widoku, a paralaksa działa: nowa wraca na ekran
	var/list/hidden_screen = list()
	var/atom/movable/screen/parallax_layer/planet_sky/third = second.replace_in(list(second), list(second), hidden_screen, "15x15")
	TEST_ASSERT(third in hidden_screen, "The new sky layer did not come back to the screen after the old one was hidden")
	qdel(third)
	qdel(second)

	// Kiedy podmieniać: tylko przy mniejszym widoku, tylko z planetą, w trakcie zejścia dopiero po pokazie
	TEST_ASSERT(aq_view_shrunk("17x15", "15x15"), "A narrower view doesn't count as shrunk")
	TEST_ASSERT(aq_view_shrunk("15x17", "15x15"), "A lower view doesn't count as shrunk")
	TEST_ASSERT(!aq_view_shrunk("15x15", "17x15"), "A wider view counts as shrunk")
	TEST_ASSERT(!aq_view_shrunk("15x15", "15x15"), "The same view counts as shrunk")
	TEST_ASSERT(fresh.needs_view_refresh(), "A sky layer with a planet is not refreshed after the view shrinks")
	fresh.descent_active = TRUE
	TEST_ASSERT(!fresh.needs_view_refresh(), "The sky layer was replaced in the middle of a descent")
	TEST_ASSERT(fresh.view_refresh_pending, "The refresh skipped during a descent is not remembered for its end")
	fresh.descent_active = FALSE
	fresh.view_refresh_pending = FALSE
	fresh.show_planet(null)
	TEST_ASSERT(!fresh.needs_view_refresh(), "A sky layer without a planet is refreshed")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
