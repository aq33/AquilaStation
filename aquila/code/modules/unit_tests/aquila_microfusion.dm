// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - broń microfusion (MCR-01): strzał zużywa ogniwo i grzeje emiter, dławienie blokuje strzał, dodatki zmieniają broń i dają się zdjąć
/datum/unit_test/aquila_microfusion

/datum/unit_test/aquila_microfusion/Run()
	var/turf/target_turf = run_loc_floor_bottom_left
	var/turf/shooter_turf = locate(target_turf.x, target_turf.y + 3, target_turf.z)
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, shooter_turf)
	var/obj/item/gun/microfusion/mcr01/gun = allocate(/obj/item/gun/microfusion/mcr01, shooter_turf)
	var/obj/item/microfusion_phase_emitter/emitter = gun.phase_emitter

	TEST_ASSERT(gun.cell, "MCR-01 spawned without a cell")
	TEST_ASSERT(emitter, "MCR-01 spawned without a phase emitter")
	TEST_ASSERT_EQUAL(gun.cell.charge, gun.cell.maxcharge, "MCR-01 cell is not full at spawn")
	TEST_ASSERT(gun.chambered?.BB, "MCR-01 has no chambered shot")

	// A shot drains the cell and heats the emitter
	var/charge_before = gun.cell.charge
	TEST_ASSERT(gun.process_fire(target_turf, shooter, FALSE), "MCR-01 did not fire")
	TEST_ASSERT_EQUAL(gun.cell.charge, charge_before - gun.microfusion_lens.e_cost, "Shot did not use the lens cost")
	TEST_ASSERT(emitter.current_heat > 0, "Shot did not heat the phase emitter")

	// The thermal throttle blocks the next shot without using power
	gun.semicd = FALSE
	emitter.current_heat = emitter.max_heat
	charge_before = gun.cell.charge
	TEST_ASSERT(!gun.process_fire(target_turf, shooter, FALSE), "MCR-01 fired over the thermal throttle")
	TEST_ASSERT_EQUAL(gun.cell.charge, charge_before, "Throttled shot used power")
	emitter.current_heat = 0

	// Scatter barrel: the lens fires three scatter pellets, removing it restores the lens
	var/obj/item/microfusion_gun_attachment/barrel/scatter/scatter = allocate(/obj/item/microfusion_gun_attachment/barrel/scatter, shooter_turf)
	TEST_ASSERT(gun.add_attachment(scatter, shooter), "Scatter barrel was not installed")
	TEST_ASSERT_EQUAL(gun.microfusion_lens.pellets, 3, "Scatter barrel pellets")
	TEST_ASSERT_EQUAL(gun.microfusion_lens.projectile_type, /obj/item/projectile/beam/laser/microfusion/scatter, "Scatter barrel projectile")
	TEST_ASSERT(istype(gun.chambered?.BB, /obj/item/projectile/beam/laser/microfusion/scatter), "Chambered shot was not refreshed by the scatter barrel")
	var/obj/item/microfusion_gun_attachment/barrel/repeater/repeater = allocate(/obj/item/microfusion_gun_attachment/barrel/repeater, shooter_turf)
	TEST_ASSERT(!gun.add_attachment(repeater, shooter), "Second barrel attachment fit into a full slot")
	gun.remove_attachment(scatter)
	TEST_ASSERT_EQUAL(gun.microfusion_lens.pellets, 1, "Pellets after removing the scatter barrel")
	TEST_ASSERT_EQUAL(gun.microfusion_lens.projectile_type, /obj/item/projectile/beam/laser/microfusion, "Projectile after removing the scatter barrel")

	// Taking the rail off drops every other attachment and undoes their stats
	var/obj/item/microfusion_gun_attachment/rail/rail = allocate(/obj/item/microfusion_gun_attachment/rail, shooter_turf)
	var/obj/item/microfusion_gun_attachment/grip/grip = allocate(/obj/item/microfusion_gun_attachment/grip, shooter_turf)
	TEST_ASSERT(gun.add_attachment(rail, shooter), "Rail was not installed")
	TEST_ASSERT(gun.can_flashlight, "Rail did not allow a flashlight")
	TEST_ASSERT(gun.add_attachment(repeater, shooter), "Repeater was not installed")
	TEST_ASSERT_EQUAL(gun.burst_size, 2, "Repeater burst size")
	TEST_ASSERT(gun.add_attachment(grip, shooter), "Grip was not installed")
	gun.remove_attachment(rail)
	TEST_ASSERT(!length(gun.attachments), "Removing the rail left attachments on the gun")
	TEST_ASSERT_EQUAL(gun.burst_size, 1, "Burst size after the rail took the repeater off")
	TEST_ASSERT_EQUAL(gun.attachment_spread, 0, "Spread after removing every attachment")
	TEST_ASSERT_EQUAL(gun.heat_per_shot, initial(gun.heat_per_shot), "Heat per shot after removing every attachment")
	TEST_ASSERT(!gun.can_flashlight, "Flashlight still allowed without the rail")

	// Ejecting discharges the cell, only an empty cell goes back in
	var/obj/item/stock_parts/cell/microfusion/old_cell = gun.cell
	gun.eject_cell()
	TEST_ASSERT(!gun.cell, "Cell still in the gun after ejecting")
	TEST_ASSERT_EQUAL(old_cell.charge, 0, "Ejected cell kept its charge")
	TEST_ASSERT(!gun.can_shoot(), "Gun can shoot without a cell")
	old_cell.charge = 100
	TEST_ASSERT(!gun.insert_cell(shooter, old_cell), "Charged cell went into the gun")
	old_cell.charge = 0
	TEST_ASSERT(gun.insert_cell(shooter, old_cell), "Empty cell did not go into the gun")
	TEST_ASSERT_EQUAL(old_cell.chargerate, 300, "Inserted cell cannot be recharged")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
