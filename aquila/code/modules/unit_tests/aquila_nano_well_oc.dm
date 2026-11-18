// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"] (expected [b], got [a])") }

/// AQUILA - moduły podkręcania studni nanonaprawczej: montaż zmienia parametr, drugi moduł tego samego rodzaju
/// jest odrzucany, łom wyjmuje moduł i przywraca parametr, a wyjęty moduł da się włożyć ponownie.
/datum/unit_test/aquila_nano_well_oc

/datum/unit_test/aquila_nano_well_oc/Run()
	var/obj/machinery/armour_plating_nanorepair_well/well = allocate(/obj/machinery/armour_plating_nanorepair_well)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human)
	var/obj/item/crowbar/crowbar = allocate(/obj/item/crowbar)
	crowbar.toolspeed = 0 // bez do_after w teście

	var/obj/item/apnw_oc_module/power/power = allocate(/obj/item/apnw_oc_module/power)
	well.attackby(power, engineer)
	TEST_ASSERT_EQUAL(power.loc, well, "moduł mocy nie trafił do studni")
	TEST_ASSERT_EQUAL(well.maximum_power_allocation, 12e6, "moduł mocy nie podniósł limitu mocy")

	var/obj/item/apnw_oc_module/power/second = allocate(/obj/item/apnw_oc_module/power)
	well.attackby(second, engineer)
	TEST_ASSERT(second.loc != well, "drugi moduł mocy nie powinien wejść do studni")

	var/obj/item/apnw_oc_module/cooling/cooling = allocate(/obj/item/apnw_oc_module/cooling)
	well.attackby(cooling, engineer)
	TEST_ASSERT_EQUAL(well.system_cooling, 2.5, "moduł chłodzenia nie zmienił chłodzenia")

	// Łom wyjmuje ostatnio włożony moduł (chłodzenie), moc zostaje
	well.power_allocation = 10e6
	TEST_ASSERT(well.crowbar_act(engineer, crowbar), "łom powinien obsłużyć studnię z modułami")
	TEST_ASSERT(cooling.loc != well, "łom nie wyjął modułu chłodzenia")
	TEST_ASSERT_EQUAL(well.system_cooling, 1, "po wyjęciu chłodzenie nie wróciło do 1")
	TEST_ASSERT_EQUAL(well.maximum_power_allocation, 12e6, "wyjęcie chłodzenia nie może ruszyć limitu mocy")

	TEST_ASSERT(well.crowbar_act(engineer, crowbar), "łom powinien wyjąć drugi moduł")
	TEST_ASSERT(power.loc != well, "łom nie wyjął modułu mocy")
	TEST_ASSERT_EQUAL(well.maximum_power_allocation, 3e6, "po wyjęciu modułu limit mocy nie wrócił do 3 MW")
	TEST_ASSERT_EQUAL(well.power_allocation, 3e6, "przydział mocy powyżej nowego limitu nie został przycięty")
	TEST_ASSERT(!well.crowbar_act(engineer, crowbar), "pusta studnia nie powinna przechwytywać łomu")

	// Przełożenie: wyjęty moduł przeciążenia wchodzi z powrotem
	var/obj/item/apnw_oc_module/load/load = allocate(/obj/item/apnw_oc_module/load)
	well.attackby(load, engineer)
	TEST_ASSERT_EQUAL(well.system_stress_threshold, 200, "moduł przeciążenia nie podniósł progu")
	well.system_stress = 350
	well.crowbar_act(engineer, crowbar)
	TEST_ASSERT_EQUAL(well.system_stress_threshold, 100, "po wyjęciu próg stresu nie wrócił do 100")
	TEST_ASSERT_EQUAL(well.system_stress, 200, "stres powyżej nowego maksimum nie został przycięty")
	well.attackby(load, engineer)
	TEST_ASSERT_EQUAL(load.loc, well, "wyjęty moduł nie dał się włożyć ponownie")
	TEST_ASSERT_EQUAL(well.system_stress_threshold, 200, "ponownie włożony moduł nie działa")

/// AQUILA - moduły podkręcania mają źródło: projekty w węźle badań i towar u Minsky Heavy Engineering
/datum/unit_test/aquila_nano_well_oc_sources

/datum/unit_test/aquila_nano_well_oc_sources/Run()
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("adv_engi")
	for(var/id in list("apnw_oc_power", "apnw_oc_load", "apnw_oc_cooling"))
		TEST_ASSERT(id in node.design_ids, "węzeł adv_engi nie ma projektu [id]")
		TEST_ASSERT(SSresearch.techweb_designs[id], "brak projektu [id]")
	var/datum/trader/minsky/trader = new
	for(var/path in list(/datum/trader_item/apnw_oc_power, /datum/trader_item/apnw_oc_load, /datum/trader_item/apnw_oc_cooling))
		TEST_ASSERT(path in trader.sold_items, "Minsky nie sprzedaje [path]")
	TEST_ASSERT(/datum/trader_item/railgun_disk in trader.sold_items, "dopisanie modułów nie może skasować reszty towaru Minsky")
	qdel(trader)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
