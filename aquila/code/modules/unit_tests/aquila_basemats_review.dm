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

/// N8: przymiotnik materiału w liczbie mnogiej i w rodzaju żeńskim rzeczowników zakończonych spółgłoską
/datum/unit_test/aquila_basemats_polish_adjective

/datum/unit_test/aquila_basemats_polish_adjective/Run()
	var/datum/material/gold = SSmaterials.GetMaterialRef(/datum/material/gold)
	var/obj/item/clothing/glasses/glasses = allocate(/obj/item/clothing/glasses)
	glasses.name = "okulary"
	TEST_ASSERT_EQUAL(gold.get_prefixed_name(glasses), "złote okulary", "Plural glasses got the wrong adjective")
	var/obj/item/paper/paper = allocate(/obj/item/paper)
	paper.name = "drzwi"
	TEST_ASSERT_EQUAL(gold.get_prefixed_name(paper), "złote drzwi", "Plural doors got the wrong adjective")
	paper.name = "kość"
	TEST_ASSERT_EQUAL(gold.get_prefixed_name(paper), "złota kość", "A feminine consonant noun got the wrong adjective")
	paper.name = "czerwony kubek"
	TEST_ASSERT_EQUAL(gold.get_prefixed_name(paper), "złoty czerwony kubek", "A masculine adjective-first name got the wrong adjective")
	paper.name = "czarne okulary"
	TEST_ASSERT_EQUAL(gold.get_prefixed_name(paper), "złote czarne okulary", "A plural adjective-first name got the wrong adjective")

/// M3: moduł cyborga (stos bez materiałów) uzupełnia się zwykłym stosem z podłogi
/datum/unit_test/aquila_basemats_cyborg_merge

/datum/unit_test/aquila_basemats_cyborg_merge/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)

	var/obj/item/stack/sheet/iron/cyborg/module_iron = allocate(/obj/item/stack/sheet/iron/cyborg, start, 1, FALSE)
	var/datum/robot_energy_storage/storage = new
	storage.energy = 0
	module_iron.source = storage
	var/obj/item/stack/sheet/iron/floor_iron = allocate(/obj/item/stack/sheet/iron, east, 3, FALSE)
	TEST_ASSERT(floor_iron.merge_check(module_iron), "A floor iron stack does not merge into a cyborg iron module")
	floor_iron.merge(module_iron)
	TEST_ASSERT_EQUAL(storage.energy, 3 * module_iron.cost, "The cyborg module did not take the floor iron")
	TEST_ASSERT(QDELETED(floor_iron), "The floor iron stack was not used up")
	module_iron.source = null
	qdel(storage)

/// M6: nowy stos z materiałem łączy się dopiero po nadaniu materiału (złote płytki nie wpadają do stosu żelaznych)
/datum/unit_test/aquila_basemats_material_tile_merge

/datum/unit_test/aquila_basemats_material_tile_merge/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/datum/material/gold_ref = SSmaterials.GetMaterialRef(/datum/material/gold)
	var/datum/material/iron_ref = SSmaterials.GetMaterialRef(/datum/material/iron)

	// Płytki ze złota z menu arkusza, gdy pod nogami leżą żelazne płytki z materiału
	var/obj/item/stack/tile/material/iron_tiles = allocate(/obj/item/stack/tile/material, start, 10, FALSE)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, start)
	var/obj/item/stack/sheet/mineral/gold/gold = allocate(/obj/item/stack/sheet/mineral/gold, start, 2, FALSE)
	builder.put_in_active_hand(gold)
	var/datum/stack_recipe/tile_recipe
	for(var/datum/stack_recipe/recipe in gold.recipes)
		if(recipe.result_type == /obj/item/stack/tile/material)
			tile_recipe = recipe
	TEST_ASSERT(tile_recipe, "Gold sheets have no material tile recipe")
	usr = builder
	gold.ui_act("make", list("ref" = REF(tile_recipe), "multiplier" = "1"))
	usr = null
	TEST_ASSERT_EQUAL(iron_tiles.amount, 10, "Crafted gold tiles merged into the iron tile pile")
	TEST_ASSERT(iron_tiles.mats_per_unit[iron_ref], "The iron tile pile changed its material")
	var/obj/item/stack/tile/material/gold_tiles
	for(var/obj/item/stack/tile/material/tiles in builder.held_items + start.contents)
		if(tiles.mats_per_unit?[gold_ref])
			gold_tiles = tiles
	TEST_ASSERT(gold_tiles, "Crafting made no gold tiles")
	TEST_ASSERT_EQUAL(gold_tiles.amount, tile_recipe.res_amount, "Crafting made the wrong number of gold tiles")
	qdel(gold_tiles)

	// Podważona złota podłoga daje złotą płytkę, nawet gdy na polu leżą żelazne
	var/old_type = east.type
	var/list/old_baseturfs = east.baseturfs
	var/turf/open/floor/material/gold_floor = east.PlaceOnTop(/turf/open/floor/material)
	gold_floor.set_custom_materials(list(/datum/material/gold = 500))
	var/obj/item/stack/tile/material/more_iron = new(gold_floor, 5, FALSE)
	gold_floor.remove_tile(silent = TRUE)
	var/iron_amount = more_iron.amount
	var/pried_gold = 0
	for(var/obj/item/stack/tile/material/tiles in east)
		if(tiles.mats_per_unit?[gold_ref])
			pried_gold += tiles.amount
	for(var/obj/item/stack/leftover in east)
		qdel(leftover)
	east.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT_EQUAL(iron_amount, 5, "A pried gold tile merged into the iron tile pile")
	TEST_ASSERT_EQUAL(pried_gold, 1, "The pried gold floor gave no gold tile")

/// M7: stos z protolatu ma materiał z typu i łączy się ze zwykłym stosem
/datum/unit_test/aquila_basemats_printed_stack_merge

/datum/unit_test/aquila_basemats_printed_stack_merge/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/obj/machinery/rnd/production/protolathe/lathe = allocate(/obj/machinery/rnd/production/protolathe, start)
	TEST_ASSERT(!lathe.efficient_with(/obj/item/stack/rods), "Protolathe stacks are still cheaper than their type materials")
	var/obj/item/stack/rods/rods = allocate(/obj/item/stack/rods, start, 5, FALSE)
	lathe.do_print(/obj/item/stack/rods, 1, list(/datum/material/iron = 400), FALSE)
	TEST_ASSERT_EQUAL(rods.amount, 5 + initial(rods.amount), "A printed rod stack did not merge with a normal one")

/// M4: trwała struktura statku pamięta materiał ściany i podłogi z materiału (i to, że pochodzi z metalgenu)
/datum/unit_test/aquila_basemats_ship_structure_materials

/datum/unit_test/aquila_basemats_ship_structure_materials/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)
	var/old_type = east.type
	var/list/old_baseturfs = east.baseturfs
	var/old_type_2 = east_2.type
	var/list/old_baseturfs_2 = east_2.baseturfs
	var/datum/ship_structure/structure = new(list(start.z), null)

	var/turf/closed/wall/material/wall = east.PlaceOnTop(/turf/closed/wall/material)
	wall.set_custom_materials(list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT * 2))
	var/wall_sig = ship_structure_turf_sig(wall)
	east.ScrapeAway()
	var/turf/restored_wall = structure.set_turf(east, wall_sig)
	var/wall_gold = aquila_test_material_amount(restored_wall, /datum/material/gold)
	var/wall_name = restored_wall.name

	var/turf/open/floor/material/floor = east_2.PlaceOnTop(/turf/open/floor/material)
	floor.set_custom_materials(list(/datum/material/iron = 500))
	metal_transmute(floor, /datum/material/diamond)
	var/floor_sig = ship_structure_turf_sig(floor)
	east_2.ScrapeAway()
	var/turf/restored_floor = structure.set_turf(east_2, floor_sig)
	var/floor_diamond = aquila_test_material_amount(restored_floor, /datum/material/diamond)
	var/floor_reclaimable = length(restored_floor.get_unit_materials())

	east.ChangeTurf(old_type, old_baseturfs)
	east_2.ChangeTurf(old_type_2, old_baseturfs_2)
	qdel(structure)
	TEST_ASSERT_EQUAL(wall_gold, MINERAL_MATERIAL_AMOUNT * 2, "A saved gold wall came back without its gold")
	TEST_ASSERT_EQUAL(wall_name, "złota ściana", "A saved gold wall came back with the wrong name")
	TEST_ASSERT_EQUAL(floor_diamond, 500, "A saved transmuted floor came back without its look")
	TEST_ASSERT(!floor_reclaimable, "A saved transmuted floor came back with reclaimable material")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
