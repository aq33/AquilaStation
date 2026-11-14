// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: powierzchnia planety wulkanicznej powstaje w rezerwacji z krawędzią, lądowiskami i terenem,
/// a po unload() rezerwacja wraca do puli
/datum/unit_test/planet_surface_generation

/datum/unit_test/planet_surface_generation/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	var/datum/planet_surface/surface = planet.surface
	TEST_ASSERT(surface, "The planet has no surface datum")
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "The surface was generated before anyone landed")
	TEST_ASSERT(surface.generate(), "The surface didn't generate")
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_READY, "The surface isn't ready after generating")
	TEST_ASSERT(planet.roomReservation == surface.reservation, "The planet doesn't point at its surface reservation")
	TEST_ASSERT_EQUAL(surface.reservation.overmap_fallback, planet, "Mobs on the surface wouldn't belong to the planet")

	var/turf/bl = surface.bottom_left()
	TEST_ASSERT(istype(bl, /turf/closed/indestructible/rock/planet_edge), "The surface corner isn't the planet edge ([bl.type])")
	var/space = 0
	var/lava = 0
	var/walls = 0
	var/list/inner = surface.inner_turfs()
	for(var/turf/T as anything in inner)
		if(isspaceturf(T))
			space++
		else if(islava(T))
			lava++
		else if(isclosedturf(T))
			walls++
	TEST_ASSERT_EQUAL(space, 0, "Space turfs left on the planet surface")
	TEST_ASSERT(walls > 0, "The lava planet has no rock (caves)")
	TEST_ASSERT(walls + lava < length(inner), "The lava planet has no walkable ground")

	TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "Wrong number of landing zones")
	for(var/turf/zone as anything in surface.landing_zones)
		for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
			TEST_ASSERT(isopenturf(T) && !islava(T), "Landing zone [surface.landing_zones[zone]] has blocked ground at [T.x],[T.y] ([T.type])")
			for(var/atom/movable/AM as anything in T)
				TEST_ASSERT(!AM.density || ismob(AM), "Landing zone [surface.landing_zones[zone]] has a dense [AM.type]")
		TEST_ASSERT(zone.loc == surface.surface_area, "Landing zone [surface.landing_zones[zone]] isn't in the planet surface area")

	var/list/reserved = surface.reservation.reserved_turfs.Copy()
	surface.unload()
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "The surface didn't unload")
	TEST_ASSERT(!planet.roomReservation, "The planet still points at a released reservation")
	var/turf/released = reserved[1]
	TEST_ASSERT(isspaceturf(released), "The released surface wasn't turned back into space ([released.type])")
	qdel(planet, TRUE)

/// AQUILA - planety: pogoda planety działa tylko w jej obszarze, a nie na całym poziomie rezerwacji
/datum/unit_test/planet_weather_area

/datum/unit_test/planet_weather_area/Run()
	var/area/planet/surface/lava/planet_area = new
	var/area/planet/surface/lava/other_area = new
	var/turf/inside = run_loc_floor_bottom_left
	var/turf/outside = get_step(inside, EAST)
	var/area/old_inside = inside.loc
	var/area/old_outside = outside.loc
	planet_area.contents += inside
	inside.change_area(old_inside, planet_area)
	other_area.contents += outside
	outside.change_area(old_outside, other_area)
	var/mob/living/carbon/human/in_storm = allocate(/mob/living/carbon/human, inside)
	var/mob/living/carbon/human/sheltered = allocate(/mob/living/carbon/human, outside)

	var/datum/weather/ash_storm/storm = new(list())
	storm.planet_area = planet_area
	storm.telegraph()
	TEST_ASSERT_EQUAL(length(storm.impacted_areas), 1, "The planet storm affects more than its planet")
	TEST_ASSERT(storm.impacted_areas[1] == planet_area, "The planet storm doesn't affect its planet")
	TEST_ASSERT(storm.can_weather_act(in_storm), "The planet storm doesn't hit people on the planet")
	TEST_ASSERT(!storm.can_weather_act(sheltered), "The planet storm hits people outside its planet")
	storm.end()
	storm.planet_area = null

	other_area.contents -= outside
	old_outside.contents += outside
	outside.change_area(other_area, old_outside)
	planet_area.contents -= inside
	old_inside.contents += inside
	inside.change_area(planet_area, old_inside)

/// Zwraca pierwsze pole lądowiska (otwarty grunt planety)
/datum/unit_test/proc/planet_ground_turf(datum/planet_surface/surface)
	for(var/turf/zone as anything in surface.landing_zones)
		return zone

// Misje w teście: „okręt” to okolica podłogi testowej (mapa testowa nie należy do głównego okrętu)
/datum/overmap_objective/planet/survey/test
	var/turf/home_turf

/datum/overmap_objective/planet/survey/test/is_delivered(atom/movable/AM)
	return get_dist(AM, home_turf) <= 3 && AM.z == home_turf.z

/datum/overmap_objective/planet/evacuation/test
	var/turf/home_turf

/datum/overmap_objective/planet/evacuation/test/is_delivered(atom/movable/AM)
	return get_dist(AM, home_turf) <= 3 && AM.z == home_turf.z

/// AQUILA - planety: pocisk wycelowany w planetę trafia ją nad środkiem, a uderzenie spada przy znaczniku z lornetki
/datum/unit_test/planet_bombardment

/datum/unit_test/planet_bombardment/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_bottom_left, /datum/planet_type/lava)
	TEST_ASSERT(planet.surface.generate(), "The surface didn't generate")
	var/turf/ground = planet_ground_turf(planet.surface)
	TEST_ASSERT(get_planet_of(ground) == planet, "A landing zone turf isn't recognised as the planet surface")
	TEST_ASSERT(!get_planet_of(run_loc_floor_bottom_left), "A ship turf is recognised as a planet surface")

	var/obj/item/projectile/bullet/mac_round/shell = new(planet.center_turf())
	shell.original = planet
	TEST_ASSERT(shell.can_hit_target(planet, TRUE), "A shell above the planet centre can't hit the planet it was fired at")
	shell.original = null
	TEST_ASSERT(!shell.can_hit_target(planet, TRUE), "A shell fired at something else hits the planet it flies over")

	var/obj/effect/planet_laser_target/laser = new(ground, "Tester")
	planet.bullet_act(shell)
	var/obj/effect/temp_visual/planet_strike/strike
	for(var/obj/effect/temp_visual/planet_strike/candidate in range(planet.strike_spread(shell), ground))
		strike = candidate
	TEST_ASSERT(strike, "The bombardment didn't land next to the laser target")
	TEST_ASSERT_EQUAL(strike.projectile_type, shell.type, "The strike doesn't remember the shell type")
	// Bez wybuchu w teście
	strike.projectile_type = null
	strike.damage = 0
	qdel(strike)
	qdel(laser)
	qdel(shell)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: kapsuła desantowa ląduje tylko na gruncie planety i zabiera siedzącego
/datum/unit_test/planet_drop_pod

/datum/unit_test/planet_drop_pod/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(planet.surface.generate(), "The surface didn't generate")
	var/turf/ground = planet_ground_turf(planet.surface)
	var/obj/machinery/drop_pod_bay/bay = allocate(/obj/machinery/drop_pod_bay, run_loc_floor_bottom_left)
	TEST_ASSERT(bay.can_land_at(ground), "The drop pod can't land on a landing zone")
	TEST_ASSERT(!bay.can_land_at(run_loc_floor_bottom_left), "The drop pod can land inside the ship")
	var/turf/lava
	for(var/turf/open/lava/L in planet.surface.inner_turfs())
		lava = L
		break
	if(lava)
		TEST_ASSERT(!bay.can_land_at(lava), "The drop pod can land in lava")

	var/mob/living/carbon/human/trooper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	bay.buckle_mob(trooper, TRUE)
	TEST_ASSERT_EQUAL(trooper.buckled, bay, "The trooper didn't sit in the drop pod")
	bay.set_target(trooper, planet, ground, "test")
	bay.machine_stat = NONE
	bay.launch(trooper)
	TEST_ASSERT(istype(trooper.loc, /obj/structure/closet/supplypod/drop_pod), "The trooper isn't in the falling pod ([trooper.loc?.type])")
	TEST_ASSERT(!bay.ready, "The bay is ready right after launching")
	// Kapsuła leci kilka sekund (tranzyt, spadanie, otwarcie): żołnierz ma wysiąść na planecie
	sleep(10 SECONDS)
	TEST_ASSERT(planet.surface.contains(get_turf(trooper)), "The trooper didn't land on the planet ([AREACOORD(trooper)])")
	TEST_ASSERT(get_dist(trooper, ground) <= 3, "The trooper landed too far from the target")
	trooper.forceMove(run_loc_floor_bottom_left)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: badanie planety zalicza się po sondzie i czterech rodzajach próbek na okręcie
/datum/unit_test/planet_survey_mission

/datum/unit_test/planet_survey_mission/Run()
	var/datum/overmap_objective/planet/survey/test/mission = new(SSstar_system.systems[1])
	mission.home_turf = run_loc_floor_bottom_left
	mission.target_planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(mission.target_planet.surface.generate(), "The surface didn't generate")
	mission.setup_site()
	TEST_ASSERT(mission.site, "The survey site wasn't placed")
	TEST_ASSERT(mission.target_planet.surface.contains(get_turf(mission.site)), "The survey site isn't on the planet")
	for(var/sample_type in list("rock", "flora", "fauna"))
		allocate(/obj/item/planet_sample, run_loc_floor_bottom_left, mission.target_planet, sample_type)
	mission.probe_done = TRUE
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 0, "The survey finished with only three kinds of samples")
	allocate(/obj/item/planet_sample, run_loc_floor_bottom_left, mission.target_planet, "atmosphere")
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 1, "The survey didn't finish with all samples delivered and the probe done")
	var/obj/structure/overmap/planet/planet = mission.target_planet
	qdel(mission)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: ewakuacja stawia schron z kolonistami i zalicza się, gdy trzech jest żywych na okręcie
/datum/unit_test/planet_evacuation_mission

/datum/unit_test/planet_evacuation_mission/Run()
	var/datum/overmap_objective/planet/evacuation/test/mission = new(SSstar_system.systems[1])
	mission.home_turf = run_loc_floor_bottom_left
	mission.target_planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(mission.target_planet.surface.generate(), "The surface didn't generate")
	mission.setup_site()
	TEST_ASSERT(mission.colony_ready, "The colony wasn't set up")
	TEST_ASSERT_EQUAL(length(mission.colonists), 4, "Wrong number of colonists")
	for(var/mob/living/carbon/human/colonist as anything in mission.colonists)
		TEST_ASSERT(mission.target_planet.surface.contains(get_turf(colonist)), "A colonist isn't on the planet")
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 0, "The evacuation finished with everyone still on the planet")
	for(var/i in 1 to 3)
		var/mob/living/carbon/human/colonist = mission.colonists[i]
		colonist.forceMove(run_loc_floor_bottom_left)
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 1, "The evacuation didn't finish with three colonists on the ship")
	var/list/colonists = mission.colonists.Copy()
	var/obj/structure/overmap/planet/planet = mission.target_planet
	qdel(mission)
	QDEL_LIST(colonists)
	planet.surface.unload()
	qdel(planet, TRUE)


#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
