// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - maskowanie generatora tarcz: sygnatura i radar wroga spadają, tarcza nie chroni, po zdjęciu generator stygnie
/datum/unit_test/shield_cloak
	var/obj/machinery/shield_generator/gen
	var/obj/structure/overmap/ship
	var/old_shields

/datum/unit_test/shield_cloak/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship for the cloak test")
	old_shields = ship.shields
	gen = new(run_loc_floor_bottom_left)
	ship.shields = gen

	var/size = ship.get_signature_size()
	var/heat = ship.get_signature_heat()
	gen.cloaked = TRUE
	TEST_ASSERT(ship.is_cloaked(), "The ship isn't cloaked with a cloaking shield generator")
	TEST_ASSERT(abs(ship.get_signature_size() - size * 0.2) < 0.001, "The cloak doesn't cut the signature size")
	TEST_ASSERT(abs(ship.get_signature_heat() - heat * 0.2) < 0.001, "The cloak doesn't cut the signature heat")

	// Tarcza w masce nie pochłania trafień
	gen.active = TRUE
	gen.shield["integrity"] = 1000
	var/obj/item/projectile/proj = new(run_loc_floor_bottom_left)
	proj.damage = 10
	TEST_ASSERT(gen.absorb_hit(proj) == SHIELD_NOEFFECT, "A cloaking shield generator still absorbs hits")
	qdel(proj)

	// Zdjęcie maski: koniec ukrycia i stygnięcie
	gen.end_cloak("test")
	TEST_ASSERT(!ship.is_cloaked(), "The ship stayed cloaked after the cloak ended")
	TEST_ASSERT(gen.cloak_ready_at > world.time, "The shield generator didn't start cooling down after the cloak")
	TEST_ASSERT(!gen.can_cloak(), "The cloak can be restarted while the generator cools down")

/datum/unit_test/shield_cloak/Destroy()
	if(ship)
		ship.shields = old_shields
		ship.alpha = 255
	QDEL_NULL(gen)
	return ..()

#undef TEST_ASSERT
