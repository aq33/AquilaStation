// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: powierzchnia planety lodowej, dżunglowej i śnieżnej karłowatej powstaje z lądowiskami na
/// bezpiecznym gruncie, krawędzią, roślinami, zwierzętami albo żyłami, a potem znika bez śladu
/datum/unit_test/planet_ice_jungle_surfaces

/datum/unit_test/planet_ice_jungle_surfaces/Run()
	for(var/planet_type in list(/datum/planet_type/ice, /datum/planet_type/jungle, /datum/planet_type/dwarf/snow))
		var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, planet_type)
		var/datum/planet_surface/surface = planet.surface
		TEST_ASSERT(surface.generate(), "[planet_type] surface didn't generate")
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		TEST_ASSERT(surface.size >= prototype.surface_size, "[planet_type] surface is smaller than its type ([surface.size])")
		// Trzecie lądowisko czasem się nie mieści obok dużej ruiny głównej (tak samo na planecie wulkanicznej)
		TEST_ASSERT(length(surface.landing_zones) >= PLANET_LANDING_ZONES - 1, "[planet_type] has only [length(surface.landing_zones)] landing zones")
		for(var/turf/zone as anything in surface.landing_zones)
			for(var/turf/T as anything in RANGE_TURFS(2, zone))
				TEST_ASSERT(!is_planet_hazard_turf(T), "[planet_type] landing zone [surface.landing_zones[zone]] has unsafe ground at [T.x],[T.y] ([T.type])")
		var/turf/bl = surface.bottom_left()
		TEST_ASSERT(istype(bl, prototype.edge_turf_type), "[planet_type] surface has no edge")
		var/content = 0
		for(var/turf/T as anything in surface.inner_turfs())
			for(var/atom/movable/thing as anything in T)
				if(istype(thing, /obj/structure/flora) || istype(thing, /obj/structure/vein) || isliving(thing) || istype(thing, /obj/structure/spacevine))
					content++
		TEST_ASSERT(content > 20, "[planet_type] surface is almost empty ([content] plants, animals and veins)")
		TEST_ASSERT(!length(GLOB.planet_greeble_spawners), "Greeble spawners are left after [planet_type] generation")
		surface.unload()
		TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "[planet_type] surface didn't unload")
		qdel(planet, TRUE)

/// AQUILA - planety: każda ruina planety lodowej i dżunglowej mieści się jako ruina główna (zwykła albo powiększona
/// powierzchnia) i się wczytuje
/datum/unit_test/planet_ice_jungle_ruins

/datum/unit_test/planet_ice_jungle_ruins/Run()
	var/list/ruin_sets = list(
		/datum/planet_type/ice = get_planet_ice_ruin_templates(),
		/datum/planet_type/jungle = get_planet_jungle_ruin_templates(),
	)
	TEST_ASSERT_EQUAL(length(ruin_sets[/datum/planet_type/ice]), 5, "Ice ruin count")
	TEST_ASSERT_EQUAL(length(ruin_sets[/datum/planet_type/jungle]), 8, "Jungle ruin count")
	for(var/planet_type in ruin_sets)
		var/list/templates = ruin_sets[planet_type]
		for(var/name in templates)
			var/datum/map_template/ruin/ruin = templates[name]
			TEST_ASSERT(ruin.width && ruin.height, "[name] map didn't load (no size)")
			TEST_ASSERT(planet_ruin_fits_surface(ruin, PLANET_SURFACE_SIZE_LARGE), "[name] ([ruin.width]x[ruin.height]) doesn't fit even a large surface")
			TEST_ASSERT(planet_test_load_ruin(ruin), "[name] didn't load")
	// Planeta, która wylosuje za dużą ruinę główną, powiększa się
	var/datum/map_template/ruin/big_ruin = ruin_sets[/datum/planet_type/jungle]["Opuszczona Baza Lotnicza"]
	TEST_ASSERT(big_ruin && !planet_ruin_fits_surface(big_ruin, PLANET_SURFACE_SIZE), "The airbase should be too big for a normal surface")

/// AQUILA - planety: każda mapa greebla lodu i dżungli z list spawnerów się wczytuje
/datum/unit_test/planet_ice_jungle_greebles

/datum/unit_test/planet_ice_jungle_greebles/Run()
	var/list/maps = list()
	for(var/spawner_type in list(/obj/effect/greeble_spawner/ice, /obj/effect/greeble_spawner/ice/anomaly, /obj/effect/greeble_spawner/jungle,
			/obj/effect/greeble_spawner/jungle/cave, /obj/effect/greeble_spawner/jungle/anomaly))
		var/obj/effect/greeble_spawner/spawner = new spawner_type(run_loc_floor_bottom_left)
		maps |= spawner.greeble_maps
		qdel(spawner)
	TEST_ASSERT(length(maps) >= 120, "Only [length(maps)] ice and jungle greeble maps are listed")
	// Każda mapa się wczytuje do pamięci (rozmiar), a kilka losowych staje na prawdziwej powierzchni w wolnym miejscu
	var/list/templates = list()
	for(var/map_path in maps)
		var/datum/map_template/template = new(map_path, "greeble test", TRUE)
		TEST_ASSERT(template.width && template.height, "Greeble map [map_path] has no size")
		templates[map_path] = template
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/jungle)
	TEST_ASSERT(planet.surface.generate(), "The jungle surface didn't generate")
	var/obj/effect/greeble_spawner/checker = new /obj/effect/greeble_spawner/jungle(run_loc_floor_bottom_left)
	var/list/inner = planet.surface.inner_turfs()
	var/loaded = 0
	for(var/i in 1 to 8)
		var/datum/map_template/template = templates[pick(templates)]
		for(var/attempt in 1 to 100)
			var/turf/spot = pick(inner)
			if(!checker.can_deploy(template, spot, planet.surface))
				continue
			TEST_ASSERT(template.load(spot, centered = TRUE), "Greeble map [template.mappath] didn't load")
			loaded++
			break
	TEST_ASSERT(loaded >= 4, "Only [loaded] of 8 sample greebles found room on a jungle surface")
	qdel(checker)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: żyły misji lodu i dżungli, ruda lodu topi się w ogniu, statyczne pnącza nie rosną
/datum/unit_test/planet_ice_jungle_content

/datum/unit_test/planet_ice_jungle_content/Run()
	for(var/planet_type in list(/datum/planet_type/ice, /datum/planet_type/jungle, /datum/planet_type/dwarf/snow))
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		for(var/vein_class in prototype.mission_veins)
			var/vein_type = prototype.get_mission_vein(vein_class)
			TEST_ASSERT(ispath(vein_type, prototype.vein_root), "[planet_type] class [vein_class] vein [vein_type] isn't under [prototype.vein_root]")
			var/obj/structure/vein/vein = allocate(vein_type, run_loc_floor_bottom_left)
			TEST_ASSERT_EQUAL(vein.vein_class, text2num(vein_class), "[vein_type] class")
			TEST_ASSERT_EQUAL(vein.deep_vein, vein.vein_class == 4, "[vein_type] deep vein flag")
	for(var/system_name in list("Gliese 581-G", "Alpha Centauri", "Medea"))
		TEST_ASSERT(length(GLOB.fixed_planets_by_system[system_name]), "[system_name] has no fixed planet")

	var/obj/item/stack/ore/ice/ice = new(run_loc_floor_bottom_left, 5)
	ice.fire_act(500, 100)
	TEST_ASSERT(QDELETED(ice), "Ice ore doesn't melt in fire")

	var/obj/structure/spacevine/dense/vine = allocate(/obj/structure/spacevine/dense, run_loc_floor_bottom_left)
	TEST_ASSERT(vine.opacity, "Dense vines don't block sight")
	TEST_ASSERT(isnull(vine.master), "Static vines have a spreading controller")
	var/obj/structure/flora/ash/garden/frigid/garden = allocate(/obj/structure/flora/ash/garden/frigid, run_loc_floor_bottom_left)
	TEST_ASSERT(garden.GetComponent(/datum/component/plant), "The garden isn't a botany plant")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
TEST_FOCUS(/datum/unit_test/planet_ice_jungle_surfaces)
TEST_FOCUS(/datum/unit_test/planet_ice_jungle_ruins)
TEST_FOCUS(/datum/unit_test/planet_ice_jungle_greebles)
TEST_FOCUS(/datum/unit_test/planet_ice_jungle_content)
TEST_FOCUS(/datum/unit_test/planet_type_selection)
TEST_FOCUS(/datum/unit_test/planet_surface_generation)
TEST_FOCUS(/datum/unit_test/planet_lava_ruins)
TEST_FOCUS(/datum/unit_test/planet_greeble)
TEST_FOCUS(/datum/unit_test/aquila_vein_drill)
TEST_FOCUS(/datum/unit_test/planet_survey_mission)
TEST_FOCUS(/datum/unit_test/planet_evacuation_mission)
