// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - podział mocy okrętu: limit odcina system ponad jego udział, priorytet zostawia prąd ważniejszym systemom
/datum/unit_test/ship_power

/datum/unit_test/ship_power/Run()
	var/datum/ship_power/power = new
	var/obj/machinery/shield = new /obj/machinery(run_loc_floor_bottom_left)
	var/obj/machinery/gun = new /obj/machinery(run_loc_floor_bottom_left)

	// Limit: tarcza o maksie 10 MW z limitem 50% dostaje 5 MW, ale nie więcej
	power.limits[SHIP_POWER_SHIELD] = 0.5
	power.priorities[SHIP_POWER_SHIELD] = 1
	power.priorities[SHIP_POWER_WEAPONS] = 3
	TEST_ASSERT(power.request(SHIP_POWER_SHIELD, 5e6, 1e9, shield, 1e7), "The shield didn't get power within its limit")
	TEST_ASSERT(!power.request(SHIP_POWER_SHIELD, 1e6, 1e9, shield, 1e7), "The shield got power over its limit")
	TEST_ASSERT(power.cap(SHIP_POWER_SHIELD) == 5e6, "The shield cap isn't half of its maximum draw")

	// Nowy cykl: tarcza (priorytet 1) poprosiła o 5 MW w poprzednim cyklu, więc broń (priorytet 3)
	// nie może ich zabrać, gdy w sieci jest tylko 6 MW wolnego prądu
	power.cycle = -1
	power.roll_cycle()
	power.limits[SHIP_POWER_WEAPONS] = 1
	TEST_ASSERT(!power.request(SHIP_POWER_WEAPONS, 2e6, 6e6, gun, 2e6), "Weapons took the power reserved for the higher priority shield")
	TEST_ASSERT(power.request(SHIP_POWER_WEAPONS, 1e6, 6e6, gun, 2e6), "Weapons didn't get the power left over the shield's reserve")
	TEST_ASSERT(power.request(SHIP_POWER_SHIELD, 5e6, 6e6, shield, 1e7), "The shield didn't get its reserved power")

	// Regresja: rezerwa tarczy w odciętej sieci B nie blokuje broni w sieci A
	var/datum/net_a = new
	var/datum/net_b = new
	power.cycle = -1
	power.roll_cycle()
	power.limits[SHIP_POWER_SHIELD] = 1
	TEST_ASSERT(!power.request(SHIP_POWER_SHIELD, 9e6, 0, shield, 1e7, net_b), "The shield got power from an empty network")
	power.cycle = -1
	power.roll_cycle()
	TEST_ASSERT(power.request(SHIP_POWER_WEAPONS, 1e6, 2e6, gun, 2e6, net_a), "The shield's request in another network blocked weapons")
	TEST_ASSERT(!power.request(SHIP_POWER_WEAPONS, 1e6, 2e6, gun, 2e6, net_b), "Weapons took the shield's reserve in the shield's own network")
	// Regresja: rezerwa w sieci B nie przekracza tego, co zostało z limitu systemu po poborze w sieci A
	var/obj/machinery/shield_b = new /obj/machinery(run_loc_floor_bottom_left)
	power.limits[SHIP_POWER_SHIELD] = 0.5
	power.cycle = -1
	power.roll_cycle()
	power.request(SHIP_POWER_SHIELD, 5e6, 0, shield, 5e6, net_a)
	power.request(SHIP_POWER_SHIELD, 5e6, 0, shield_b, 5e6, net_b)
	power.cycle = -1
	power.roll_cycle()
	TEST_ASSERT(power.request(SHIP_POWER_SHIELD, 5e6, 1e9, shield, 5e6, net_a), "The shield in network A didn't get the whole system limit")
	TEST_ASSERT(power.request(SHIP_POWER_WEAPONS, 2e6, 6e6, gun, 2e6, net_b), "A reserve over the exhausted shield limit blocked weapons in network B")
	qdel(shield_b)
	qdel(net_a)
	qdel(net_b)

	// Limit 0% odcina system całkowicie, a gotowe ustawienie przywraca limity
	power.limits[SHIP_POWER_WEAPONS] = 0
	TEST_ASSERT(!power.request(SHIP_POWER_WEAPONS, 1, 1e9, gun, 2e6), "A system at 0% still draws power")
	TEST_ASSERT(power.apply_preset("Walka"), "The combat preset doesn't exist")
	TEST_ASSERT(power.limits[SHIP_POWER_WEAPONS] == 1 && power.priorities[SHIP_POWER_SHIELD] == 1, "The combat preset didn't set limits and priorities")
	TEST_ASSERT(!power.apply_preset("Nie ma takiego"), "An unknown preset was applied")

	qdel(shield)
	qdel(gun)
	qdel(power)

#undef TEST_ASSERT
