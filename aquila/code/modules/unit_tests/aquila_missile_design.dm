// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - projekt pocisku: chip w obudowie przechodzi na gotową torpedę i na pocisk, a moduły zmieniają jego parametry
/datum/unit_test/missile_design
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/casing
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/warhead
	var/obj/item/ship_weapon/ammunition/torpedo/built
	var/obj/item/projectile/guided_munition/torpedo/proj
	var/obj/item/missile_design_chip/chip

/datum/unit_test/missile_design/Run()
	var/datum/missile_design/D = new
	D.name = "Test"
	D.engine = "sprint"
	D.body = "opancerzony"
	D.seeker = "brak"
	TEST_ASSERT(abs(D.mult("speed") - 0.6 * 1.15 * 0.9) < 0.001, "Speed modifiers of the design don't multiply")
	TEST_ASSERT(abs(D.mult("integrity") - 1.8) < 0.001, "The armoured body doesn't raise integrity")
	TEST_ASSERT(D.mult("turn") == 0, "An unguided design can still turn")

	// Chip do obudowy, głowica w obudowie, jak przy składaniu
	casing = new(run_loc_floor_bottom_left)
	chip = new(run_loc_floor_bottom_left)
	chip.design = D
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	casing.insert_missile_design_chip(chip, user)
	TEST_ASSERT(casing.GetComponent(/datum/component/missile_design), "The design chip didn't program the casing")
	chip = null
	warhead = new(casing)
	built = new /obj/item/ship_weapon/ammunition/torpedo(run_loc_floor_bottom_left)
	transfer_forged_munition(warhead, built)
	var/datum/component/missile_design/MD = built.GetComponent(/datum/component/missile_design)
	TEST_ASSERT(MD && MD.design.name == "Test", "The design didn't pass from the casing to the finished torpedo")

	// Z torpedy na pocisk: parametry i brak naprowadzania
	proj = new(run_loc_floor_bottom_left)
	var/base_speed = proj.speed
	var/base_integrity = proj.max_integrity
	var/base_range = proj.range
	transfer_forged_munition(built, proj)
	TEST_ASSERT(abs(proj.speed - base_speed * D.mult("speed")) < 0.001, "The design didn't change the projectile speed")
	TEST_ASSERT(proj.max_integrity == round(base_integrity * 1.8), "The design didn't change the projectile integrity")
	TEST_ASSERT(proj.range == round(base_range * 0.6), "The sprint engine didn't shorten the range")
	TEST_ASSERT(!proj.homing, "An unguided projectile still homes")

	// Podczerwień gubi zimny cel
	var/datum/component/missile_design/PMD = proj.GetComponent(/datum/component/missile_design)
	PMD.design.seeker = "podczerwień"
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(ship)
		var/old_heat = ship.thrust_heat
		var/old_damp = ship.inertial_dampeners
		var/old_fire = ship.last_weapon_fire
		ship.thrust_heat = 0
		ship.inertial_dampeners = FALSE
		ship.last_weapon_fire = -INFINITY
		if(ship.get_signature_heat() < 0.12)
			TEST_ASSERT(isnull(PMD.seek(proj, ship)), "An infrared seeker kept a cold target")
		ship.thrust_heat = 2
		TEST_ASSERT(PMD.seek(proj, ship) == ship, "An infrared seeker lost a hot target")
		ship.thrust_heat = old_heat
		ship.inertial_dampeners = old_damp
		ship.last_weapon_fire = old_fire

/datum/unit_test/missile_design/Destroy()
	QDEL_NULL(proj)
	QDEL_NULL(built)
	QDEL_NULL(warhead)
	QDEL_NULL(casing)
	QDEL_NULL(chip)
	return ..()

#undef TEST_ASSERT
