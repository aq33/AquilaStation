// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - pożar podłogi nie pali przedmiotu w trakcie usuwania (zawartość niszczonego moba wysypuje się na płonący kafelek)
/datum/unit_test/turf_fire_ignores_deleted_items

/datum/unit_test/turf_fire_ignores_deleted_items/Run()
	var/turf/open/floor = run_loc_floor_bottom_left
	var/obj/effect/abstract/turf_fire/magical/fire = new(floor)
	var/obj/item/stock_parts/cell/computer/cell = new(floor)
	qdel(cell)
	var/runtimes_before = GLOB.total_runtimes
	fire.on_entered(floor, cell)
	var/runtimes_after = GLOB.total_runtimes
	qdel(fire)
	TEST_ASSERT(runtimes_after == runtimes_before, "The floor fire damaged an item that was being deleted")

#undef TEST_ASSERT
