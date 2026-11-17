// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Broń okrętowa bez rdzenia i overmapy: liczy oddane strzały zamiast strzelać
/obj/machinery/ship_weapon/aq_salvo_test
	var/fired_shots = 0
	var/test_ammo = 3

/obj/machinery/ship_weapon/aq_salvo_test/can_fire(atom/target, shots = linked_overmap_ship_weapon.burst_size)
	return test_ammo >= shots

/obj/machinery/ship_weapon/aq_salvo_test/get_ammo()
	return test_ammo

/obj/machinery/ship_weapon/aq_salvo_test/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	fired_shots += shots
	test_ammo -= shots
	return TRUE

/// Typy towarów, które handlarz wystawia po uzupełnieniu (bez ofert specjalnych, które wymagają okrętu gracza)
/proc/aq_test_trader_stock(trader_type)
	var/datum/trader/trader = new trader_type()
	trader.system = SSstar_system.systems[1]
	trader.special_offers = list()
	trader.stock_items()
	. = list()
	for(var/datum/trader_item/item as anything in trader.stonks)
		. += item.type
	QDEL_LIST(trader.stonks)
	qdel(trader)

/// Ile strzałów oddaje datum broni z jednego działa z trzema pociskami
/proc/aq_test_salvo_shots(weapon_type, turf/target)
	var/datum/overmap_ship_weapon/weapon = new weapon_type()
	var/obj/machinery/ship_weapon/aq_salvo_test/gun = new(target)
	weapon.weapons["loaded"] += gun
	weapon.weapons["all"] += gun
	gun.linked_overmap_ship_weapon = weapon
	weapon.fire_physical(target)
	. = gun.fired_shots
	gun.linked_overmap_ship_weapon = null
	weapon.weapons["loaded"] -= gun
	weapon.weapons["all"] -= gun
	qdel(gun)
	qdel(weapon)

/// AQUILA - raport nsv_martwe_08 pkt 1: Yamato z badań i od Minsky'ego, salwa trzech pocisków, przeładowanie 7 s
/datum/unit_test/nsv_yamato

/datum/unit_test/nsv_yamato/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("macro_ballistics")
	TEST_ASSERT("deck_gun_triple" in node.design_ids, "Makrobalistyka nie ma płytki Yamato")
	TEST_ASSERT(!("deck_gun_triple" in SSresearch.gun_techdesigns), "Wyłączenie trybu trudnego zdjęłoby płytkę Yamato z badań")

	var/obj/machinery/ship_weapon/deck_turret/_3/yamato_type = /obj/machinery/ship_weapon/deck_turret/_3
	TEST_ASSERT_EQUAL(initial(yamato_type.weapon_datum_type), /datum/overmap_ship_weapon/mac/yamato, "Yamato strzela zwykłym datumem artylerii")
	var/datum/overmap_ship_weapon/mac/yamato/yamato_datum = /datum/overmap_ship_weapon/mac/yamato
	TEST_ASSERT_EQUAL(initial(yamato_datum.fire_delay), 7 SECONDS, "Złe przeładowanie Yamato")

	TEST_ASSERT_EQUAL(aq_test_salvo_shots(/datum/overmap_ship_weapon/mac/yamato, run_loc_floor_bottom_left), 3, "Yamato nie wystrzelił salwy trzech pocisków")
	TEST_ASSERT_EQUAL(aq_test_salvo_shots(/datum/overmap_ship_weapon/mac, run_loc_floor_bottom_left), 1, "Hood zaczął strzelać salwą")

	var/list/stock = aq_test_trader_stock(/datum/trader/minsky)
	TEST_ASSERT(/datum/trader_item/deck_gun_triple in stock, "Minsky nie sprzedaje płytki Yamato")
	TEST_ASSERT(/datum/trader_item/railgun_disk in stock, "Minsky zgubił swój zwykły towar")

/// AQUILA - raport nsv_martwe_08 pkt 2: działa z trybu trudnego w badaniu „Uzbrojenie okrętowe” i u handlarzy
/datum/unit_test/nsv_ship_armament

/datum/unit_test/nsv_ship_armament/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("ship_armament")
	TEST_ASSERT(node != SSresearch.error_node, "Nie ma badania Uzbrojenie okrętowe")
	TEST_ASSERT("macro_ballistics" in node.prereq_ids, "Uzbrojenie okrętowe nie wymaga Makrobalistyki")
	TEST_ASSERT(node.research_costs[TECHWEB_POINT_TYPE_GENERIC] >= 10000, "Uzbrojenie okrętowe jest za tanie")
	for(var/design_id in list("gauss_dispenser_circuit", "gauss_turret", "ship_firing_electronics", "deck_gun", "vls_tube"))
		TEST_ASSERT(design_id in node.design_ids, "Uzbrojenie okrętowe nie ma projektu [design_id]")
		TEST_ASSERT(SSresearch.techweb_design_by_id(design_id) != SSresearch.error_design, "Nie ma projektu [design_id]")
	// Pusta lista: włączenie trybu trudnego nic nie dokłada, a wyłączenie niczego nie zdejmuje z badań
	TEST_ASSERT_EQUAL(length(SSresearch.gun_techdesigns), 0, "Tryb trudny nadal ma własne projekty dział")

	var/list/stock = aq_test_trader_stock(/datum/trader/armsdealer)
	for(var/item_type in list(/datum/trader_item/gauss_turret_circuit, /datum/trader_item/gauss_dispenser_circuit, /datum/trader_item/deck_turret_circuit, /datum/trader_item/torpedo))
		TEST_ASSERT(item_type in stock, "White Rapids nie sprzedaje [item_type]")
	stock = aq_test_trader_stock(/datum/trader/minsky)
	TEST_ASSERT(/datum/trader_item/firing_electronics in stock, "Minsky nie sprzedaje elektroniki spustowej")
	TEST_ASSERT(/datum/trader_item/vls_circuit in stock, "Minsky nie sprzedaje płytki VLS")
	// Towar dopisany w innym pliku zostaje
	TEST_ASSERT(/datum/trader_item/deck_gun_triple in stock, "Minsky zgubił płytkę Yamato")
	stock = aq_test_trader_stock(/datum/trader/armsdealer/syndicate)
	TEST_ASSERT(!(/datum/trader_item/gauss_turret_circuit in stock), "DonkCo sprzedaje płytki White Rapids")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
