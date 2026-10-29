// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Hotspots burn their tile and smoke only every few ticks
/datum/unit_test/hotspot_throttle

/datum/unit_test/hotspot_throttle/Run()
	var/turf/open/location = run_loc_floor_bottom_left
	// Earlier tests may have left smoke around
	QDEL_NULL(location.pollution)

	var/obj/effect/hotspot/hotspot = allocate(/obj/effect/hotspot, location)
	TEST_ASSERT(!QDELETED(hotspot), "The hotspot did not survive Initialize()")
	TEST_ASSERT(hotspot.exposure_count == 1, "Initialize() did not do the first exposure (count [hotspot.exposure_count])")
	TEST_ASSERT(location.pollution?.pollutants[/datum/pollutant/smoke] > 0, "The first exposure did not smoke")

	var/burns = 0
	for(var/i in 1 to HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL)
		if(hotspot.throttled_exposure(location))
			burns++
	TEST_ASSERT(burns == HOTSPOT_SMOKE_INTERVAL, "The hotspot burned its tile [burns] times in [HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL] ticks instead of [HOTSPOT_SMOKE_INTERVAL]")

	QDEL_NULL(location.pollution)

/// AQUILA - Ash in a fire still bakes into ash rims, but quietly
/datum/unit_test/fire_mutes_reaction

/datum/unit_test/fire_mutes_reaction/Run()
	var/turf/open/location = run_loc_floor_bottom_left
	var/obj/effect/decal/cleanable/ash/ash = allocate(/obj/effect/decal/cleanable/ash, location)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker, location)
	TEST_ASSERT(!fire_mutes_reaction(ash), "Ash outside a fire reacts quietly")

	var/obj/effect/hotspot/hotspot = allocate(/obj/effect/hotspot, location)
	TEST_ASSERT(fire_mutes_reaction(ash), "Ash in a fire still reacts with a sound and a message")
	TEST_ASSERT(!fire_mutes_reaction(beaker), "A beaker in a fire reacts quietly")

	ash.reagents.expose_temperature(1000, 1)
	var/rims = 0
	for(var/obj/item/garnish/ash/rim in location)
		rims++
	TEST_ASSERT(rims > 0, "Ash heated in a fire did not bake into ash rims")

	// More ash on the same tile stops at the cap
	for(var/i in 1 to 3)
		var/obj/effect/decal/cleanable/ash/more_ash = allocate(/obj/effect/decal/cleanable/ash, location)
		more_ash.reagents.expose_temperature(1000, 1)
	rims = 0
	for(var/obj/item/garnish/ash/rim in location)
		rims++
		qdel(rim)
	TEST_ASSERT(rims == MAX_ASH_RIMS_PER_TURF, "A tile has [rims] ash rims instead of the cap of [MAX_ASH_RIMS_PER_TURF]")
	qdel(hotspot)
	QDEL_NULL(location.pollution)

/// AQUILA - Burning gas heats a hotspot tile's contents only every few ticks
/datum/unit_test/fire_exposes_contents

/datum/unit_test/fire_exposes_contents/Run()
	var/turf/open/location = run_loc_floor_bottom_left
	TEST_ASSERT(fire_exposes_contents(location), "A tile without a hotspot is not heated every time")

	var/obj/effect/hotspot/hotspot = allocate(/obj/effect/hotspot, location)
	var/heats = 0
	for(var/i in 1 to HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL)
		if(fire_exposes_contents(location))
			heats++
		hotspot.exposure_count++
	TEST_ASSERT(heats == HOTSPOT_SMOKE_INTERVAL, "A burning tile's contents were heated [heats] times in [HOTSPOT_SMOKE_INTERVAL * HOTSPOT_CONTENTS_INTERVAL] ticks instead of [HOTSPOT_SMOKE_INTERVAL]")
	qdel(hotspot)
	QDEL_NULL(location.pollution)

#undef TEST_ASSERT
