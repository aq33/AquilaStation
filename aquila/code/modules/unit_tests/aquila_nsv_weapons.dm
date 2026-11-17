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

// Datumy broni bez overmapy: liczą amunicję tylko z podpiętych dział
/datum/overmap_ship_weapon/mac/aq_test/needs_real_weapons()
	return TRUE

/datum/overmap_ship_weapon/mac/yamato/aq_test/needs_real_weapons()
	return TRUE

/datum/overmap_ship_weapon/flak/aq_test/needs_real_weapons()
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

	TEST_ASSERT_EQUAL(aq_test_salvo_shots(/datum/overmap_ship_weapon/mac/yamato/aq_test, run_loc_floor_bottom_left), 3, "Yamato nie wystrzelił salwy trzech pocisków")
	TEST_ASSERT_EQUAL(aq_test_salvo_shots(/datum/overmap_ship_weapon/mac/aq_test, run_loc_floor_bottom_left), 1, "Hood zaczął strzelać salwą")

	var/list/stock = aq_test_trader_stock(/datum/trader/minsky)
	TEST_ASSERT(/datum/trader_item/deck_gun_triple in stock, "Minsky nie sprzedaje płytki Yamato")
	TEST_ASSERT(/datum/trader_item/railgun_disk in stock, "Minsky zgubił swój zwykły towar")

/// AQUILA - raport nsv_martwe_08 pkt 2: działa z trybu trudnego w badaniu „Uzbrojenie okrętowe” i u handlarzy
/datum/unit_test/nsv_ship_armament

/datum/unit_test/nsv_ship_armament/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("ship_weaponry")
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

/// AQUILA - raport nsv_martwe_08 pkt 3: moduł kalibracji działa pokładowego działa, wygasa i daje się skalibrować multitoolem
/datum/unit_test/nsv_deck_gun_calibrator

/datum/unit_test/nsv_deck_gun_calibrator/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("ship_weaponry")
	TEST_ASSERT("deck_gun_calibrator" in node.design_ids, "Uzbrojenie okrętowe nie ma płytki modułu kalibracji")
	TEST_ASSERT(/datum/trader_item/deck_gun_calibrator in aq_test_trader_stock(/datum/trader/armsdealer), "White Rapids nie sprzedaje modułu kalibracji")

	var/turf/center = get_step(run_loc_floor_bottom_left, NORTHEAST)
	var/obj/machinery/deck_turret/core/core = allocate(/obj/machinery/deck_turret/core, center)
	TEST_ASSERT_EQUAL(core.get_calibrator(), null, "Rdzeń widzi moduł kalibracji, którego nie ma")
	var/obj/machinery/deck_turret/calibrator/calibrator = allocate(/obj/machinery/deck_turret/calibrator, get_step(center, EAST))
	TEST_ASSERT_EQUAL(core.get_calibrator(), calibrator, "Nowy moduł kalibracji obok rdzenia nie działa")

	// Pocisk ze skalibrowanego działa: dłuższe i ostrzejsze naprowadzanie
	var/obj/item/projectile/bullet/mac_round/round = allocate(/obj/item/projectile/bullet/mac_round, center)
	round.homing = TRUE
	round.aq_calibrate()
	TEST_ASSERT_EQUAL(round.homing_turn_speed, initial(round.homing_turn_speed) * 2, "Skalibrowany pocisk nie skręca ostrzej")
	round.stop_homing() // Zwykły timer po 0,2 s
	TEST_ASSERT(round.homing, "Skalibrowany pocisk przestał się naprowadzać po 0,2 s")
	round.aq_homing_until = world.time
	round.stop_homing()
	TEST_ASSERT(!round.homing, "Skalibrowany pocisk naprowadza się bez końca")

	// Po kwadransie moduł nic nie daje, dopóki ktoś go nie skalibruje multitoolem
	calibrator.lose_calibration()
	TEST_ASSERT_EQUAL(core.get_calibrator(), null, "Moduł bez kalibracji nadal działa")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(calibrator, NORTH))
	var/obj/item/multitool/tool = allocate(/obj/item/multitool, get_step(calibrator, NORTH))
	tool.toolspeed = 0.01
	user.put_in_active_hand(tool)
	calibrator.multitool_act(user, tool)
	TEST_ASSERT_EQUAL(core.get_calibrator(), calibrator, "Multitool nie skalibrował modułu")

/// AQUILA - raport nsv_martwe_08 pkt 4: Magneton i Sparrowhawk z badań i od White Rapids, lepsze od zwykłej amunicji
/datum/unit_test/nsv_magneton_sparrowhawk

/datum/unit_test/nsv_magneton_sparrowhawk/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("macro_ballistics")
	TEST_ASSERT("naval_shell_homing" in node.design_ids, "Makrobalistyka nie ma Magnetonu")
	node = SSresearch.techweb_node_by_id("advanced_torpedo_components")
	TEST_ASSERT("cruise_missile_warhead" in node.design_ids, "Amunicja kierowana II nie ma głowicy Sparrowhawka")
	var/list/stock = aq_test_trader_stock(/datum/trader/armsdealer)
	TEST_ASSERT(/datum/trader_item/naval_shell_homing in stock, "White Rapids nie sprzedaje Magnetonu")
	TEST_ASSERT(/datum/trader_item/cruise_missile in stock, "White Rapids nie sprzedaje Sparrowhawka")

	var/obj/item/projectile/bullet/mac_round/magneton/magneton = /obj/item/projectile/bullet/mac_round/magneton
	var/obj/item/projectile/bullet/mac_round/shell = /obj/item/projectile/bullet/mac_round
	TEST_ASSERT(initial(magneton.damage) > initial(shell.damage), "Magneton jest słabszy od zwykłego pocisku")
	var/obj/item/projectile/guided_munition/missile/cruise/cruise = /obj/item/projectile/guided_munition/missile/cruise
	var/obj/item/projectile/guided_munition/missile/missile = /obj/item/projectile/guided_munition/missile
	TEST_ASSERT(initial(cruise.damage) > initial(missile.damage), "Sparrowhawk jest słabszy od zwykłej rakiety")
	TEST_ASSERT(initial(cruise.range) > initial(missile.range), "Sparrowhawk nie leci dalej od zwykłej rakiety")
	var/obj/item/ship_weapon/parts/missile/warhead/cruise/warhead = /obj/item/ship_weapon/parts/missile/warhead/cruise
	TEST_ASSERT_EQUAL(initial(warhead.build_path), /obj/item/ship_weapon/ammunition/missile/cruise, "Głowica Sparrowhawka składa inną rakietę")

	// Sparrowhawk da się przewieźć i wtoczyć do VLS, ale nie do wyrzutni myśliwca
	var/obj/machinery/ship_weapon/vls/vls = allocate(/obj/machinery/ship_weapon/vls, run_loc_floor_bottom_left)
	var/obj/item/ship_weapon/ammunition/missile/cruise/sparrowhawk = allocate(/obj/item/ship_weapon/ammunition/missile/cruise, get_step(run_loc_floor_bottom_left, EAST))
	TEST_ASSERT(!sparrowhawk.anchored, "Sparrowhawk jest przykręcony do podłogi")
	var/obj/item/fighter_component/secondary/ordnance_launcher/rack = allocate(/obj/item/fighter_component/secondary/ordnance_launcher)
	TEST_ASSERT(!rack.load(null, sparrowhawk), "Wyrzutnia myśliwca przyjęła Sparrowhawka")
	sparrowhawk.forceMove(get_turf(vls))
	TEST_ASSERT(sparrowhawk in vls.ammo, "VLS nie przyjął Sparrowhawka")
	TEST_ASSERT_EQUAL(sparrowhawk.projectile_type, /obj/item/projectile/guided_munition/missile/cruise, "Sparrowhawk strzela zwykłą rakietą")

// Profesje bez przydziału do drużyny: register_squad() po 5 s trafiłby w usunięte już moby testu.
// Inna frakcja, żeby SSjob nie wziął ich za prawdziwe profesje (SetupOccupations() bierze tylko „Station”)
/datum/job/cook/aq_test
	faction = "aq_test"

/datum/job/cook/aq_test/register_squad(mob/living/H)
	return

/datum/job/janitor/aq_test
	faction = "aq_test"

/datum/job/janitor/aq_test/register_squad(mob/living/H)
	return

/// AQUILA - raport nsv_martwe_08 pkt 5: przepis na głodny worek prochu zna kucharz, i tylko on
/datum/unit_test/nsv_cook_hungry_powder

/datum/unit_test/nsv_cook_hungry_powder/Run()
	var/datum/crafting_recipe/hungrypowder/recipe = locate() in GLOB.crafting_recipes
	TEST_ASSERT(recipe, "Nie ma przepisu na głodny worek prochu")
	TEST_ASSERT(recipe.crafting_flags & CRAFT_MUST_BE_LEARNED, "Głodny worek prochu może zrobić każdy")

	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human)
	cook.mind_initialize()
	var/datum/job/cook/aq_test/cook_job = new
	cook_job.after_spawn(cook, cook)
	qdel(cook_job)
	TEST_ASSERT(cook.mind.learned_recipes && (/datum/crafting_recipe/hungrypowder in cook.mind.learned_recipes), "Kucharz nie zna przepisu na głodny worek prochu")

	var/mob/living/carbon/human/janitor = allocate(/mob/living/carbon/human)
	janitor.mind_initialize()
	var/datum/job/janitor/aq_test/janitor_job = new
	janitor_job.after_spawn(janitor, janitor)
	qdel(janitor_job)
	TEST_ASSERT(!(janitor.mind.learned_recipes && (/datum/crafting_recipe/hungrypowder in janitor.mind.learned_recipes)), "Woźny zna przepis kucharza")

/// AQUILA - raport nsv_martwe_08 pkt 6: stojak flaku z mapy strzela, a płytkę flaku da się wydrukować z badań
/datum/unit_test/nsv_flak

/datum/unit_test/nsv_flak/Run()
	// Stojak z mapy (Atlantis): add_weapon() tworzy datum przez new(overmapa), bez liczby baterii
	var/datum/overmap_ship_weapon/flak/flak = new /datum/overmap_ship_weapon/flak/aq_test()
	var/obj/machinery/ship_weapon/aq_salvo_test/rack = new(run_loc_floor_bottom_left)
	flak.link_physical_weapon(rack)
	flak.weapons["loaded"] += rack
	TEST_ASSERT(flak.burst_size >= 1, "Flak ze stojaka ma salwę [isnull(flak.burst_size) ? "null" : flak.burst_size]")
	var/shots = flak.fire_physical(run_loc_floor_bottom_left)
	flak.unlink_physical_weapon(rack, TRUE)
	qdel(rack)
	qdel(flak)
	TEST_ASSERT_EQUAL(shots, 1, "Stojak flaku nie strzela")
	// Okręt AI z podaną liczbą baterii zachowuje swoją salwę
	var/datum/overmap_ship_weapon/flak/battery = new(null, TRUE, 3)
	TEST_ASSERT_EQUAL(battery.burst_size, 3, "Zmieniła się salwa flaku okrętów AI")
	qdel(battery)

	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("adv_ballistics")
	TEST_ASSERT("flak_mount_circuit" in node.design_ids, "Zaawansowana balistyka nie ma płytki flaku")
	var/datum/design/design = SSresearch.techweb_design_by_id("flak_mount_circuit")
	TEST_ASSERT_EQUAL(design.build_path, /obj/item/circuitboard/machine/pdc_mount/flak, "Projekt płytki flaku robi inną płytkę")
	TEST_ASSERT("flak_ammo" in node.design_ids, "Zaawansowana balistyka nie ma amunicji flak")
	design = SSresearch.techweb_design_by_id("flak_ammo")
	TEST_ASSERT_EQUAL(design.build_path, /obj/item/ammo_box/magazine/nsv/flak, "Projekt amunicji flak robi coś innego")
	var/datum/supply_pack/munitions/flak_ammo/pack = SSshuttle.supply_packs[/datum/supply_pack/munitions/flak_ammo]
	TEST_ASSERT(pack, "Nie ma paczki amunicji flak w zaopatrzeniu")
	TEST_ASSERT(/obj/item/ammo_box/magazine/nsv/flak in pack.contains, "Paczka amunicji flak nie ma magazynków flak")
	var/obj/item/circuitboard/machine/pdc_mount/flak/board = /obj/item/circuitboard/machine/pdc_mount/flak
	TEST_ASSERT_EQUAL(initial(board.build_path), /obj/machinery/ship_weapon/pdc_mount/flak, "Płytka flaku buduje inny stojak")
	var/obj/machinery/ship_weapon/pdc_mount/flak/mount = /obj/machinery/ship_weapon/pdc_mount/flak
	TEST_ASSERT_EQUAL(initial(mount.circuit), /obj/item/circuitboard/machine/pdc_mount/flak, "Rozebrany stojak flaku oddaje płytkę PDC")

/// Flak okrętu AI: zamiast pocisków liczy salwy, które wysłałby na overmapę
/datum/overmap_ship_weapon/flak/aq_ai_test
	var/fired_bursts = 0

/datum/overmap_ship_weapon/flak/aq_ai_test/async_nonphysical_fire(atom/target, mob/living/firer, ai_aim = FALSE, active_burst_size, list/snowflake_projectile_list)
	fired_bursts += active_burst_size

/// AQUILA - flak okrętów AI tworzony bez liczby baterii (np. lotniskowiec Syndykatu) strzela
/datum/unit_test/nsv_flak_ai

/datum/unit_test/nsv_flak_ai/Run()
	var/datum/overmap_ship_weapon/flak/plain = new(null, FALSE)
	TEST_ASSERT_EQUAL(plain.burst_size, 1, "Flak bez liczby baterii ma salwę [isnull(plain.burst_size) ? "null" : plain.burst_size]")
	qdel(plain)

	var/was_enabled = GLOB.ai_guns_last_resort_enabled
	GLOB.ai_guns_last_resort_enabled = FALSE
	var/z = run_loc_floor_bottom_left.z
	var/obj/structure/overmap/small_craft/combat/light/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/combat/light/target = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.ai_controlled = TRUE
	target.faction = "syndicate"
	ship.forceMove(locate(100, 60, z))
	target.forceMove(locate(100, 70, z))
	ship.light_shots_left = 100
	// Tak jak okręty Syndykatu w apply_weapons(): new /datum/overmap_ship_weapon/flak(src, FALSE)
	var/datum/overmap_ship_weapon/flak/aq_ai_test/flak = new(ship, FALSE)
	var/shots = flak.fire_proc_chain(target)
	var/bursts = flak.fired_bursts
	ship.ai_controlled = FALSE
	GLOB.ai_guns_last_resort_enabled = was_enabled
	qdel(flak)
	TEST_ASSERT_EQUAL(shots, 1, "Flak okrętu AI nie oddał strzału")
	TEST_ASSERT_EQUAL(bursts, 1, "Flak okrętu AI nie wysłał pocisku")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
