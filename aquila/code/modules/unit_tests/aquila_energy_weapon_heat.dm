// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Ciepło broni energetycznej (BeeStation/NSV13#2677): strzał grzeje, wbudowane chłodzenie i chłodnice studzą,
/// magazyn ciepła podnosi próg, przegrzanie blokuje strzał do ostygnięcia, a chłodnica z mapy łączy się sama
/datum/unit_test/aquila_energy_weapon_heat

/datum/unit_test/aquila_energy_weapon_heat/Run()
	var/obj/machinery/ship_weapon/energy/weapon = allocate(/obj/machinery/ship_weapon/energy, run_loc_floor_bottom_left)
	TEST_ASSERT(weapon.maintainable, "Fazer seryjny nie wymaga serwisu")
	var/obj/machinery/ship_weapon/energy/laser_pd/point_defense = allocate(/obj/machinery/ship_weapon/energy/laser_pd, run_loc_floor_top_right)
	TEST_ASSERT(!point_defense.maintainable, "Laser obrony punktowej wymaga serwisu")

	// Strzał grzeje, a bez chłodnic broń stygnie wbudowanym chłodzeniem
	weapon.maint_wear()
	TEST_ASSERT(weapon.heat == weapon.heat_per_shot, "Strzał dał [weapon.heat] ciepła zamiast [weapon.heat_per_shot]")
	weapon.process_heat()
	TEST_ASSERT(weapon.heat == weapon.heat_per_shot - weapon.heat_rate, "Wbudowane chłodzenie zbiło ciepło do [weapon.heat]")

	// Chłodnica i magazyn ciepła: dwa razy szybsze stygnięcie i wyższy próg
	var/obj/machinery/cooling/cooler/cooler = allocate(/obj/machinery/cooling/cooler, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/machinery/cooling/storage/storage = allocate(/obj/machinery/cooling/storage, locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	cooler.auto_link()
	storage.auto_link()
	TEST_ASSERT(cooler.parent == weapon && storage.parent == weapon, "Chłodnica albo magazyn ciepła nie połączyły się z bronią w tym samym obszarze")
	cooler.set_machine_stat(cooler.machine_stat & ~NOPOWER)
	storage.set_machine_stat(storage.machine_stat & ~NOPOWER)
	weapon.heat = 100
	weapon.process_heat()
	TEST_ASSERT(weapon.heat == 100 - 2 * weapon.heat_rate, "Z chłodnicą broń ostygła do [weapon.heat] zamiast [100 - 2 * weapon.heat_rate]")
	TEST_ASSERT(weapon.max_heat == initial(weapon.max_heat) + weapon.storage_rate, "Magazyn ciepła nie podniósł progu (próg [weapon.max_heat])")
	cooler.on = FALSE
	weapon.process_heat()
	TEST_ASSERT(weapon.cooling_amount == 1, "Wyłączona chłodnica dalej chłodzi")

	// Przegrzanie: blokada strzału i stygnięcie w trybie awaryjnym
	weapon.heat = weapon.max_heat + 100 // chłodzenie zbija ciepło przed sprawdzeniem progu
	weapon.process_heat()
	TEST_ASSERT(weapon.weapon_state == 2, "Broń z ciepłem ponad próg nie przegrzała się")
	TEST_ASSERT(!weapon.can_fire(null, 0), "Przegrzana broń może strzelać")
	reset_room_air() // przegrzanie wypuszcza gorącą parę, a kolejne testy (np. kwiat trupi) sprawdzają ciśnienie na tej sali
	weapon.heat = 0
	weapon.process_heat()
	TEST_ASSERT(weapon.weapon_state == 0 && weapon.icon == initial(weapon.icon), "Ostygnięta broń nie wróciła do pracy")
	TEST_ASSERT(weapon.alignment == 0 && weapon.freq == 0, "Przegrzanie nie wyzerowało soczewek i strojenia")
	// Bez serwisu broń odmawia strzału, ale nie przegrzewa się od nowa (AMS strzela sam i wpadał w pętlę przeciążeń z parą)
	weapon.charge = weapon.charge_per_shot * 2
	TEST_ASSERT(!weapon.can_fire(null, 0), "Broń po przegrzaniu strzela bez serwisu")
	TEST_ASSERT(weapon.weapon_state == 0 && weapon.charge == weapon.charge_per_shot * 2, "Próba strzału po przegrzaniu znowu przeciążyła broń")

	// Odprowadzanie ciepła blokuje strzał do 1/4 progu
	weapon.alignment = 100
	weapon.freq = 100
	weapon.heat = weapon.max_heat * 0.6
	TEST_ASSERT(weapon.vent(), "Odprowadzanie nie ruszyło przy 60% ciepła")
	TEST_ASSERT(!weapon.can_fire(null, 0), "Broń strzela w trakcie odprowadzania")
	weapon.heat = weapon.max_heat * 0.2
	weapon.process_heat()
	TEST_ASSERT(weapon.weapon_state == 0, "Odprowadzanie nie skończyło się poniżej 1/4 progu")
	TEST_ASSERT(weapon.can_fire(null, 0), "Sprawna broń nie może strzelać")
	reset_room_air()

/// AMS bez żywych torped nie strzela i nie traci ładunku: cele sprawdza przed can_fire(), które może wywołać overload()
/datum/unit_test/aquila_ams_dead_targets
	var/obj/structure/overmap/small_craft/combat/light/ship

/datum/unit_test/aquila_ams_dead_targets/Run()
	var/obj/machinery/ship_weapon/energy/ams/ams = allocate(/obj/machinery/ship_weapon/energy/ams, run_loc_floor_bottom_left)
	ship = new(run_loc_floor_top_right)
	ams.linked = ship
	var/obj/item/dead_torpedo = allocate(/obj/item/stack/rods, run_loc_floor_bottom_left)
	qdel(dead_torpedo)
	ship.torpedoes_to_target = list(dead_torpedo)
	ams.charge = ams.charge_per_shot * 10
	ams.freq = 0 // rozstrojona broń: can_fire() mogłoby wywołać overload() i wyzerować ładunek
	var/charge_before = ams.charge
	TEST_ASSERT(!ams.fire(null, 1, FALSE), "AMS strzelił bez żywych torped")
	TEST_ASSERT(ams.charge == charge_before, "AMS bez celów stracił ładunek ([ams.charge] z [charge_before])")
	TEST_ASSERT(!length(ams.aq_ams_live_targets(ship.torpedoes_to_target)), "Zniszczona torpeda liczy się jako cel")

/datum/unit_test/aquila_ams_dead_targets/Destroy()
	if(ship)
		ship.torpedoes_to_target = list()
	QDEL_NULL(ship)
	return ..()

/datum/unit_test/aquila_energy_weapon_heat/Destroy()
	reset_room_air() // także po nieudanej asercji, która przerywa Run() przed resetem
	return ..()

/// Przywraca sali testowej początkowe powietrze (overload() wypuszcza 200 moli pary o 1000 K)
/datum/unit_test/aquila_energy_weapon_heat/proc/reset_room_air()
	for(var/turf/open/room_turf in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		room_turf.air.copy_from_turf(room_turf)
		room_turf.update_visuals()

#undef TEST_ASSERT
