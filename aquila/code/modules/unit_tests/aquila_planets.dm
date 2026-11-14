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
	var/obj/structure/overmap/planet/planet = new(null, /datum/planet_type/lava)
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


#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
