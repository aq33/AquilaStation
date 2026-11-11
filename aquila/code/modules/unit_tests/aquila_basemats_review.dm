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

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
