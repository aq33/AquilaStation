// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - a split cable coil keeps its colour, and coils of another colour (or omni and coloured) do not merge
/datum/unit_test/aquila_cable_coil_colour

/datum/unit_test/aquila_cable_coil_colour/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)

	var/obj/item/stack/cable_coil/red = allocate(/obj/item/stack/cable_coil, start, 10, FALSE, null, "red")
	var/obj/item/stack/cable_coil/part = red.change_stack(null, 3)
	if(istype(part))
		allocated += part
	TEST_ASSERT(istype(part), "change_stack() did not make a new coil")
	TEST_ASSERT(!part.omni, "A piece split from a red coil became omni")
	TEST_ASSERT_EQUAL(part.cable_color, "red", "A piece split from a red coil lost its colour")

	var/obj/item/stack/cable_coil/yellow = allocate(/obj/item/stack/cable_coil, east, 5, FALSE, null, "yellow")
	TEST_ASSERT(!part.merge_check(yellow), "A red coil wants to merge with a yellow one")
	TEST_ASSERT(!part.merge(yellow), "A red coil merged into a yellow one")
	TEST_ASSERT_EQUAL(yellow.amount, 5, "A red coil merged into a yellow one")
	TEST_ASSERT_EQUAL(part.amount, 3, "A red coil merged into a yellow one")

	// A coloured coil made on a tile with an omni coil (a cut cable) stays a separate stack
	var/obj/item/stack/cable_coil/omni = allocate(/obj/item/stack/cable_coil, east_2, 5, FALSE)
	TEST_ASSERT(!omni.merge_check(part), "An omni coil wants to merge with a red one")
	var/obj/item/stack/cable_coil/dropped = allocate(/obj/item/stack/cable_coil, east_2, 2, TRUE, null, "red")
	TEST_ASSERT(!QDELETED(dropped), "A red coil merged into the omni coil on its tile")
	TEST_ASSERT_EQUAL(omni.amount, 5, "A red coil merged into the omni coil on its tile")

	// The same colour still merges
	TEST_ASSERT(part.merge_check(red), "Two red coils do not merge")
	part.merge(red)
	TEST_ASSERT_EQUAL(red.amount, 10, "Two red coils did not merge")

/// AQUILA - a plumbing transfer keeps purity and pH instead of resetting them to the creation values
/datum/unit_test/aquila_plumbing_keeps_purity

/datum/unit_test/aquila_plumbing_keeps_purity/Run()
	var/obj/item/reagent_containers/glass/beaker/source = allocate(/obj/item/reagent_containers/glass/beaker)
	var/obj/item/reagent_containers/glass/beaker/target = allocate(/obj/item/reagent_containers/glass/beaker)
	source.reagents.add_reagent(/datum/reagent/water, 10, added_purity = 0.5, added_ph = 5)

	var/moved_amount = source.reagents.plumbing_transfer(target.reagents, 10)
	TEST_ASSERT_EQUAL(moved_amount, 10, "plumbing_transfer() did not move the water")
	var/datum/reagent/moved = target.reagents.get_reagent(/datum/reagent/water)
	TEST_ASSERT(moved, "The water did not arrive")
	TEST_ASSERT_EQUAL(moved.purity, 0.5, "A plumbing transfer changed the purity")
	TEST_ASSERT_EQUAL(moved.ph, 5, "A plumbing transfer changed the pH")

/// AQUILA - a movable light gives back exactly the lumcount it added: negative lights (darkspawn, Anti-Glow) left -1 behind, LIGHT_NO_LUMCOUNT adds none
/datum/unit_test/aquila_movable_light_lumcount

/datum/unit_test/aquila_movable_light_lumcount/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/before = start.dynamic_lumcount

	var/obj/effect/dummy/lighting_obj/dark = allocate(/obj/effect/dummy/lighting_obj, start, 2, -2)
	var/darkened = start.dynamic_lumcount
	qdel(dark)
	TEST_ASSERT(darkened < before, "A negative light did not lower the lumcount of its turf")
	TEST_ASSERT_EQUAL(start.dynamic_lumcount, before, "A removed negative light left lumcount behind")

	var/obj/effect/dummy/lighting_obj/spark = allocate(/obj/effect/dummy/lighting_obj, start)
	TEST_ASSERT(start.dynamic_lumcount > before, "A light did not raise the lumcount of its turf")
	spark.set_light_flags(spark.light_flags | LIGHT_NO_LUMCOUNT)
	TEST_ASSERT_EQUAL(start.dynamic_lumcount, before, "A light with LIGHT_NO_LUMCOUNT still counts")
	qdel(spark)
	TEST_ASSERT_EQUAL(start.dynamic_lumcount, before, "A removed LIGHT_NO_LUMCOUNT light changed the lumcount")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
