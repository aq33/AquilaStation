// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - nowe ładunki pocisków: dyfuzor drenuje tarczę celu, sonda zostawia boję widzianą tylko przez swoją frakcję,
/// a głowice składają się w gotową amunicję
/datum/unit_test/missile_payloads
	var/obj/machinery/shield_generator/gen
	var/obj/structure/overmap/ship
	var/old_shields

/datum/unit_test/missile_payloads/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship for the payload test")
	old_shields = ship.shields
	gen = new(run_loc_floor_bottom_left)
	ship.shields = gen
	gen.active = TRUE
	gen.shield["max_integrity"] = 1000
	gen.shield["integrity"] = 1000

	// Dyfuzor torpedy: połowa tarczy znika jeszcze przed pochłonięciem trafienia
	var/obj/item/projectile/guided_munition/torpedo/diffuser/torp = new(run_loc_floor_bottom_left)
	ship.bullet_act(torp)
	TEST_ASSERT(gen.shield["integrity"] <= 500 - torp.damage + 1, "The diffuser torpedo didn't drain half of the shield, integrity [gen.shield["integrity"]]")
	qdel(torp)

	// Zwykła torpeda nie drenuje tarczy ponad swoje obrażenia
	gen.shield["integrity"] = 1000
	var/obj/item/projectile/guided_munition/torpedo/plain = new(run_loc_floor_bottom_left)
	ship.bullet_act(plain)
	TEST_ASSERT(abs(gen.shield["integrity"] - (1000 - plain.damage)) < 1, "A plain torpedo should take exactly its damage off the shield, integrity [gen.shield["integrity"]]")
	qdel(plain)

	// Sonda: boja na overmapie, widoczna dla frakcji, która ją wystrzeliła
	var/obj/item/projectile/guided_munition/torpedo/sensor_probe/probe = new(get_turf(ship))
	probe.overmap_firer = ship
	TEST_ASSERT(probe.damage == 0 && !probe.projectile_relaying_allowed, "The sensor probe deals damage or gets relayed into the ship")
	probe.drop_sensor_probe(get_turf(ship))
	var/obj/effect/overmap_sensor_probe/buoy = locate() in get_turf(ship)
	TEST_ASSERT(buoy && buoy.faction == ship.faction, "The sensor probe didn't drop a buoy for the firing ship's faction")
	TEST_ASSERT(buoy in ship.get_own_sensor_probes(), "The ship doesn't see its own sensor buoy")
	TEST_ASSERT(buoy.reveals(ship), "The buoy doesn't cover the tile it sits on")
	qdel(buoy)
	qdel(probe)

	// Regresja: sonda trafiająca w okręt z podniesioną tarczą też zostawia boję (tarcza kończy bullet_act przed spec_overmap_hit)
	gen.active = TRUE
	gen.shield["integrity"] = 1000
	var/obj/item/projectile/guided_munition/torpedo/sensor_probe/shielded_probe = new(get_turf(ship))
	shielded_probe.overmap_firer = ship
	ship.bullet_act(shielded_probe)
	var/obj/effect/overmap_sensor_probe/shield_buoy = locate() in get_turf(ship)
	TEST_ASSERT(shield_buoy, "A sensor probe hitting a shielded ship didn't drop a buoy")
	qdel(shield_buoy)
	qdel(shielded_probe)

	// Głowice składają się w swoją amunicję
	var/list/expected = list(
		/obj/item/ship_weapon/parts/missile/warhead/emp = /obj/item/ship_weapon/ammunition/missile/emp,
		/obj/item/ship_weapon/parts/missile/warhead/diffuser = /obj/item/ship_weapon/ammunition/torpedo/diffuser,
		/obj/item/ship_weapon/parts/missile/warhead/diffuser_missile = /obj/item/ship_weapon/ammunition/missile/diffuser,
		/obj/item/ship_weapon/parts/missile/warhead/sensor_probe = /obj/item/ship_weapon/ammunition/torpedo/sensor_probe
	)
	for(var/warhead_type in expected)
		var/obj/item/ship_weapon/parts/missile/warhead/warhead = warhead_type
		TEST_ASSERT(initial(warhead.build_path) == expected[warhead_type], "[warhead_type] builds the wrong munition")
	var/obj/item/ship_weapon/parts/missile/warhead/diffuser/torpedo_diffuser = allocate(/obj/item/ship_weapon/parts/missile/warhead/diffuser, run_loc_floor_bottom_left)
	TEST_ASSERT(torpedo_diffuser.fits_type == /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing, "The torpedo diffuser doesn't fit a torpedo casing")

/datum/unit_test/missile_payloads/Destroy()
	if(ship)
		ship.shields = old_shields
	QDEL_NULL(gen)
	return ..()

#undef TEST_ASSERT
