// AQUILA - testy regresji poprawek materiałów z przeglądu aq33/AquilaStation#613
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// M1: analizator destrukcyjny odzyskuje z jednego arkusza tylko ten arkusz i przelicza sumę materiałów stosu
/datum/unit_test/aquila_basemats_analyzer_reclaim

/datum/unit_test/aquila_basemats_analyzer_reclaim/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)

	var/obj/machinery/rnd/production/protolathe/lathe = allocate(/obj/machinery/rnd/production/protolathe, east)
	var/obj/machinery/computer/rdconsole/core/console = allocate(/obj/machinery/computer/rdconsole/core, east_2)
	var/obj/machinery/rnd/destructive_analyzer/analyzer = allocate(/obj/machinery/rnd/destructive_analyzer, start)
	analyzer.linked_console = console
	console.linked_destroy = analyzer
	console.linked_lathe = lathe
	analyzer.decon_mod = 10
	var/datum/component/material_container/storage = lathe.materials.mat_container
	TEST_ASSERT(storage, "The protolathe has no material container")
	var/datum/material/gold_ref = SSmaterials.GetMaterialRef(/datum/material/gold)
	var/gold_before = storage.get_material_amount(gold_ref)

	var/obj/item/stack/sheet/mineral/gold/gold = allocate(/obj/item/stack/sheet/mineral/gold, analyzer, 5, FALSE)
	analyzer.loaded_item = gold
	analyzer.destroy_item(gold)
	analyzer.destroy_item(gold)

	TEST_ASSERT_EQUAL(storage.get_material_amount(gold_ref) - gold_before, MINERAL_MATERIAL_AMOUNT * 2, "Destroying 2 gold sheets reclaimed the wrong amount of gold")
	TEST_ASSERT_EQUAL(gold.amount, 3, "The analyzer destroyed the wrong number of sheets")
	TEST_ASSERT_EQUAL(LAZYACCESS(gold.custom_materials, gold_ref), MINERAL_MATERIAL_AMOUNT * 3, "The stack total of materials is stale after the analyzer used a sheet")

/// M2, N8: metalgen zmienia tylko wygląd: przemieniony materiał nie wraca z recyklera ani z rozbiórki, a własna nazwa zostaje
/datum/unit_test/aquila_basemats_metalgen_no_value

/datum/unit_test/aquila_basemats_metalgen_no_value/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)

	var/obj/machinery/modular_fabricator/autolathe/lathe = allocate(/obj/machinery/modular_fabricator/autolathe, east_2)
	var/datum/component/material_container/container = lathe.GetComponent(/datum/component/material_container)

	// Żelazny klucz przemieniony w bluespace: wygląd i nazwa bluespace, ale autolat nic z niego nie odzyska
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, start)
	TEST_ASSERT(container.get_item_material_amount(wrench), "An iron wrench gives no material to the autolathe, pick another item")
	metal_transmute(wrench, /datum/material/bluespace)
	TEST_ASSERT(aquila_test_material_amount(wrench, /datum/material/bluespace), "Metalgen did not transmute the wrench")
	TEST_ASSERT(!container.get_item_material_amount(wrench), "A transmuted wrench gives material to the autolathe")
	TEST_ASSERT(!container.insert_item(wrench), "The autolathe took a transmuted wrench")

	// Przedmiot bez materiału nie dostaje materiału z niczego
	var/obj/item/paper/paper = allocate(/obj/item/paper, start)
	metal_transmute(paper, /datum/material/gold)
	TEST_ASSERT(!length(paper.get_unit_materials()), "A paper without materials gained reclaimable gold from metalgen")
	TEST_ASSERT_EQUAL(paper.name, "złota kartka", "A transmuted paper has no material adjective")
	metal_transmute(paper, /datum/material/silver)
	TEST_ASSERT_EQUAL(paper.name, "srebrna kartka", "A paper transmuted twice has the wrong name")

	// Własna nazwa zostaje (przed portem metalgen dopisywał przymiotnik tylko do nazwy z typu)
	var/obj/item/paper/letter = allocate(/obj/item/paper, start)
	letter.name = "List do mamy"
	metal_transmute(letter, /datum/material/gold)
	TEST_ASSERT_EQUAL(letter.name, "List do mamy", "Metalgen changed a custom name")
	metal_transmute(letter, /datum/material/diamond)
	TEST_ASSERT_EQUAL(letter.name, "List do mamy", "A second transmutation reset a custom name")

	// Złote krzesło przemienione w diament: rozbiórka nie daje diamentu
	var/obj/structure/chair/greyscale/chair = allocate(/obj/structure/chair/greyscale, east)
	chair.set_custom_materials(list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT))
	metal_transmute(chair, /datum/material/diamond)
	chair.deconstruct()
	TEST_ASSERT(!(locate(/obj/item/stack/sheet/mineral/diamond) in east), "A transmuted chair gave diamond back")
	for(var/obj/item/stack/leftover in east)
		qdel(leftover)

	// Ściana z materiału przemieniona w diament: bez diamentu, ale dźwigar zostaje
	var/old_type = east.type
	var/list/old_baseturfs = east.baseturfs
	var/turf/closed/wall/material/wall = east.PlaceOnTop(/turf/closed/wall/material)
	wall.set_custom_materials(list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 2))
	metal_transmute(wall, /datum/material/diamond)
	wall.dismantle_wall()
	var/diamond_refund = locate(/obj/item/stack/sheet/mineral/diamond) in east
	var/girder = locate(/obj/structure/girder) in east
	for(var/atom/movable/leftover in east)
		if(istype(leftover, /obj/structure/girder) || istype(leftover, /obj/item/stack))
			qdel(leftover)
	east.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(!diamond_refund, "A transmuted material wall gave diamond back")
	TEST_ASSERT(girder, "A transmuted material wall left no girder")

/// N7: kamień z gorgium nie ma arkusza: ściana zostawia dźwigar, a krzesło da się rozebrać
/datum/unit_test/aquila_basemats_rock_refund

/datum/unit_test/aquila_basemats_rock_refund/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)

	var/obj/structure/chair/greyscale/chair = allocate(/obj/structure/chair/greyscale, start)
	chair.set_custom_materials(list(/datum/material/rock = MINERAL_MATERIAL_AMOUNT))
	chair.deconstruct()
	TEST_ASSERT(QDELETED(chair), "A stone chair could not be deconstructed")

	var/old_type = east.type
	var/list/old_baseturfs = east.baseturfs
	var/turf/closed/wall/material/wall = east.PlaceOnTop(/turf/closed/wall/material)
	wall.set_custom_materials(list(/datum/material/rock = MINERAL_MATERIAL_AMOUNT * 2))
	wall.dismantle_wall()
	var/girder = locate(/obj/structure/girder) in east
	var/turf_after = east.type
	for(var/atom/movable/leftover in east)
		if(istype(leftover, /obj/structure/girder) || istype(leftover, /obj/item/stack))
			qdel(leftover)
	east.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(girder, "A stone material wall left no girder")
	TEST_ASSERT(!ispath(turf_after, /turf/closed/wall), "A stone material wall was not dismantled")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
