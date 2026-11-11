// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Ile danego materiału ma atom (custom_materials trzyma instancje materiałów)
/proc/aquila_test_material_amount(atom/target, material_type)
	return LAZYACCESS(target.custom_materials, SSmaterials.GetMaterialRef(material_type))

/// AQUILA - BeeStation/BeeStation-Hornet#9386: wartość monet z materiału i nasze wyjątki (żetony, heretyk, mithril, moneta z mapy)
/datum/unit_test/aquila_basemats_coins

/datum/unit_test/aquila_basemats_coins/Run()
	var/list/expected = list(
		/obj/item/coin/iron = 1,
		/obj/item/coin/silver = 10,
		/obj/item/coin/gold = 25,
		/obj/item/coin/diamond = 100,
		/obj/item/coin/plasma = 40,
		/obj/item/coin/uranium = 20,
		/obj/item/coin/bananium = 200,
		/obj/item/coin/adamantine = 100,
		/obj/item/coin/titanium = 25,
		/obj/item/coin/plastic = 5,
		/obj/item/coin/twoheaded = 1,
		/obj/item/coin/mythril = 300,
		/obj/item/coin/arcade_token = 0,
		/obj/item/coin/antagtoken = 0,
		/obj/item/coin/eldritch = 0,
	)
	for(var/coin_type in expected)
		var/obj/item/coin/coin = allocate(coin_type)
		TEST_ASSERT_EQUAL(coin.get_item_credit_value(), expected[coin_type], "[coin_type] is worth the wrong amount")

	var/obj/item/coin/gold/gold = allocate(/obj/item/coin/gold)
	TEST_ASSERT_EQUAL(gold.name, "złota moneta", "A gold coin has no Polish material adjective")
	var/obj/item/coin/arcade_token/token = allocate(/obj/item/coin/arcade_token)
	TEST_ASSERT(!token.GetComponent(/datum/component/slippery), "The arcade token slips like bananium")
	TEST_ASSERT(!token.GetComponent(/datum/component/squeak), "The arcade token squeaks like bananium")
	TEST_ASSERT_EQUAL(token.name, "żeton automatu", "The arcade token got a material prefix")
	var/obj/item/coin/bananium/clown_coin = allocate(/obj/item/coin/bananium)
	TEST_ASSERT(clown_coin.GetComponent(/datum/component/slippery), "A bananium coin does not slip (material effects are off)")
	var/obj/item/coin/eldritch/eldritch = allocate(/obj/item/coin/eldritch)
	TEST_ASSERT_EQUAL(eldritch.name, initial(eldritch.name), "The heretic coin got a material prefix")
	TEST_ASSERT(!eldritch.color, "The heretic coin was tinted by plasma")

	// Mennica bije zwykłą monetę i nadaje jej materiał
	var/obj/item/coin/minted = allocate(/obj/item/coin)
	minted.set_custom_materials(list(/datum/material/gold = 400))
	TEST_ASSERT_EQUAL(minted.get_item_credit_value(), 25, "A minted gold coin is not worth its gold")
	TEST_ASSERT_EQUAL(minted.name, "złota moneta", "A minted gold coin kept the iron name")
	TEST_ASSERT_EQUAL(length(minted.custom_materials), 1, "A minted coin kept its iron")

	// Kolekcjonerska moneta z Babylonu ma value_override na mapie
	var/obj/item/coin/iron/collectible = allocate(/obj/item/coin/iron)
	collectible.value_override = 660
	collectible.set_custom_materials(list(/datum/material/iron = 400))
	TEST_ASSERT_EQUAL(collectible.get_item_credit_value(), 660, "value_override does not survive new materials")

/// AQUILA - BeeStation/BeeStation-Hornet#10135: stosy trzymają materiał na sztukę, a dzielenie i łączenie go nie gubi
/datum/unit_test/aquila_basemats_stacks

/datum/unit_test/aquila_basemats_stacks/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)

	var/obj/item/stack/sheet/mineral/gold/gold = allocate(/obj/item/stack/sheet/mineral/gold, start, 10, FALSE)
	TEST_ASSERT_EQUAL(aquila_test_material_amount(gold, /datum/material/gold), 20000, "custom_materials of a stack is not the whole stack")
	var/list/per_unit = gold.mats_per_unit
	var/obj/item/stack/sheet/mineral/gold/part = gold.change_stack(null, 3)
	if(istype(part))
		allocated += part
	TEST_ASSERT(istype(part), "change_stack() did not make a new stack")
	TEST_ASSERT(part.mats_per_unit == per_unit, "A split stack lost its material")
	TEST_ASSERT_EQUAL(aquila_test_material_amount(part, /datum/material/gold), 6000, "A split stack has the wrong material total")
	TEST_ASSERT_EQUAL(aquila_test_material_amount(gold, /datum/material/gold), 14000, "The source stack did not lose the split material")
	part.merge(gold)
	TEST_ASSERT_EQUAL(gold.amount, 10, "Merging the split stack back failed")
	TEST_ASSERT_EQUAL(aquila_test_material_amount(gold, /datum/material/gold), 20000, "A merged stack has the wrong material total")
	gold.use(4)
	TEST_ASSERT_EQUAL(aquila_test_material_amount(gold, /datum/material/gold), 12000, "use() did not update the materials")

	// Płytki z materiału łączą się tylko z tym samym materiałem
	var/obj/item/stack/tile/material/gold_tiles = allocate(/obj/item/stack/tile/material, start, 4, FALSE)
	gold_tiles.set_mats_per_unit(list(/datum/material/gold = 500))
	var/obj/item/stack/tile/material/silver_tiles = allocate(/obj/item/stack/tile/material, east, 4, FALSE)
	silver_tiles.set_mats_per_unit(list(/datum/material/silver = 500))
	var/obj/item/stack/tile/material/more_gold = allocate(/obj/item/stack/tile/material, east_2, 2, FALSE)
	more_gold.set_mats_per_unit(list(/datum/material/gold = 500))
	TEST_ASSERT(!gold_tiles.merge_check(silver_tiles), "Gold and silver material tiles merge")
	TEST_ASSERT(gold_tiles.merge_check(more_gold), "Two gold material tiles do not merge")
	TEST_ASSERT_EQUAL(gold_tiles.name, "złota płytka podłogowa", "A gold material tile has the wrong name")

	// set_custom_materials() na stosie (metalgen, przeliczanie) ustawia ilość na sztukę
	silver_tiles.set_custom_materials(list(/datum/material/diamond = 2000))
	TEST_ASSERT_EQUAL(silver_tiles.mats_per_unit[SSmaterials.GetMaterialRef(/datum/material/diamond)], 500, "set_custom_materials() on a stack did not divide by the amount")

	// Metalgen nie przemienia stosów (recyklery czytają custom_materials)
	metal_transmute(gold, /datum/material/diamond)
	TEST_ASSERT(gold.mats_per_unit == per_unit, "Metalgen turned a gold stack into another material")

	// Plazma i bananium działają jak w Bee
	var/obj/item/stack/sheet/mineral/plasma/plasma = allocate(/obj/item/stack/sheet/mineral/plasma, east_2, 50, FALSE)
	TEST_ASSERT(plasma.GetComponent(/datum/component/explodable), "A plasma stack is not explodable")

/// AQUILA - BeeStation/BeeStation-Hornet#10135, #10703: krzesło, stół i płytka z materiału oddają materiał przy rozbiórce
/datum/unit_test/aquila_basemats_furniture

/datum/unit_test/aquila_basemats_furniture/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)

	// Receptury z materiału trafiły do list arkuszy z MAT_CATEGORY_BASE_RECIPES
	var/datum/stack_recipe/chair_recipe
	var/datum/stack_recipe/tile_recipe
	for(var/datum/stack_recipe/recipe in GLOB.gold_recipes)
		if(recipe.result_type == /obj/structure/chair/greyscale)
			chair_recipe = recipe
		if(recipe.result_type == /obj/item/stack/tile/material)
			tile_recipe = recipe
	TEST_ASSERT(chair_recipe?.applies_mats, "Gold sheets have no material chair recipe")
	TEST_ASSERT(tile_recipe?.applies_mats, "Gold sheets have no material tile recipe")
	for(var/list/recipes in list(GLOB.metal_recipes, GLOB.wood_recipes, GLOB.meat_recipes, GLOB.plastic_recipes, GLOB.adamantine_recipes))
		TEST_ASSERT(chair_recipe in recipes, "A base material sheet has no material chair recipe")
	TEST_ASSERT(!(chair_recipe in GLOB.glass_recipes), "Glass got the material chair recipe")

	// Krzesło jak z ui_act() stosu: materiał z arkusza
	var/obj/item/stack/sheet/mineral/gold/gold = allocate(/obj/item/stack/sheet/mineral/gold, start, 5, FALSE)
	var/obj/structure/chair/greyscale/chair = allocate(/obj/structure/chair/greyscale, east)
	chair.set_custom_materials(gold.mats_per_unit, chair_recipe.req_amount / chair_recipe.res_amount)
	TEST_ASSERT_EQUAL(chair.name, "złote krzesło", "The gold chair has the wrong name")
	TEST_ASSERT(chair.color, "The gold chair is not tinted")
	chair.deconstruct()
	var/obj/item/stack/sheet/mineral/gold/chair_refund = locate() in east
	TEST_ASSERT(chair_refund, "The gold chair gave no gold back")
	TEST_ASSERT_EQUAL(chair_refund.amount, 1, "The gold chair gave the wrong amount of gold back")
	qdel(chair_refund)

	// Stół z ramy i arkusza z materiałem
	var/obj/structure/table_frame/frame = allocate(/obj/structure/table_frame, east_2)
	frame.make_new_table(/obj/structure/table/greyscale, null, list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT))
	var/obj/structure/table/greyscale/table = locate() in east_2
	TEST_ASSERT(table, "The frame did not make a material table")
	allocated += table
	TEST_ASSERT_EQUAL(table.name, "srebrny stół", "The silver table has the wrong name")
	table.deconstruct(TRUE, TRUE)
	var/obj/item/stack/sheet/mineral/silver/table_refund = locate() in east_2
	TEST_ASSERT(table_refund, "The silver table gave no silver back")
	TEST_ASSERT_EQUAL(table_refund.amount, 1, "The silver table gave the wrong amount of silver back")
	qdel(table_refund)
	for(var/obj/item/stack/rods/rods in east_2)
		qdel(rods)

	// Płytka z materiału kładzie podłogę z materiału, a podważona podłoga oddaje płytkę z tym samym materiałem
	var/turf/plating_turf = east
	var/old_type = plating_turf.type
	var/list/old_baseturfs = plating_turf.baseturfs
	plating_turf.ChangeTurf(/turf/open/floor/plating)
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, start)
	var/obj/item/stack/tile/material/tiles = allocate(/obj/item/stack/tile/material, start, 4, FALSE)
	tiles.set_mats_per_unit(gold.mats_per_unit, tile_recipe.req_amount / tile_recipe.res_amount)
	builder.put_in_active_hand(tiles)
	plating_turf.attackby(tiles, builder)
	var/turf/open/floor/material/material_floor = plating_turf
	if(!istype(material_floor))
		plating_turf.ChangeTurf(old_type, old_baseturfs)
		return Fail("A material tile laid [plating_turf.type] instead of a material floor")
	var/gold_on_floor = aquila_test_material_amount(material_floor, /datum/material/gold)
	var/floor_name = material_floor.name
	material_floor.remove_tile(silent = TRUE)
	var/obj/item/stack/tile/material/pried = locate() in plating_turf
	var/pried_gold = pried ? aquila_test_material_amount(pried, /datum/material/gold) : 0
	if(pried)
		qdel(pried)
	plating_turf.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT_EQUAL(gold_on_floor, 500, "The material floor has the wrong amount of gold")
	TEST_ASSERT_EQUAL(floor_name, "złota podłoga", "The gold floor has the wrong name")
	TEST_ASSERT_EQUAL(pried_gold, 500, "The pried material tile lost its gold")

/// AQUILA - BeeStation/BeeStation-Hornet#10703 i #11340: dźwigar z arkuszem z materiałem daje nieprzezroczystą ścianę z materiału
/datum/unit_test/aquila_basemats_walls

/datum/unit_test/aquila_basemats_walls/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)
	var/old_type = east.type
	var/list/old_baseturfs = east.baseturfs

	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, start)
	var/obj/structure/girder/girder = allocate(/obj/structure/girder, east)
	var/obj/item/stack/sheet/cotton/cloth/cloth = allocate(/obj/item/stack/sheet/cotton/cloth, start, 2, FALSE)
	builder.put_in_active_hand(cloth)
	girder.attackby(cloth, builder)
	TEST_ASSERT(!QDELETED(girder) && !isclosedturf(east), "Cloth on a girder made a wall")
	TEST_ASSERT_EQUAL(cloth.amount, 2, "Cloth on a girder was used up")
	qdel(cloth)

	var/obj/item/stack/sheet/plastic/plastic = allocate(/obj/item/stack/sheet/plastic, start, 2, FALSE)
	builder.put_in_active_hand(plastic)
	girder.attackby(plastic, builder)
	var/turf/closed/wall/material/wall = east
	if(!istype(wall))
		east.ChangeTurf(old_type, old_baseturfs)
		return Fail("Plastic on a girder made [east.type] instead of a material wall")
	var/plastic_in_wall = aquila_test_material_amount(wall, /datum/material/plastic)
	var/wall_name = wall.name
	var/wall_opaque = wall.opacity
	wall.dismantle_wall()
	var/obj/item/stack/sheet/plastic/refund = locate() in east
	var/refund_amount = refund?.amount
	for(var/atom/movable/leftover in east)
		if(istype(leftover, /obj/structure/girder) || istype(leftover, /obj/item/stack))
			qdel(leftover)
	east.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT_EQUAL(plastic_in_wall, MINERAL_MATERIAL_AMOUNT * 2, "The plastic wall has the wrong amount of plastic")
	TEST_ASSERT_EQUAL(wall_name, "plastikowa ściana", "The plastic wall has the wrong name")
	TEST_ASSERT(wall_opaque, "A material wall without alpha is see-through")
	TEST_ASSERT_EQUAL(refund_amount, 2, "The plastic wall gave the wrong amount of plastic back")

	// Szkło (alpha 150) robi ścianę przezroczystą, a zdjęcie materiału przywraca nieprzezroczystość
	var/turf/closed/wall/material/glass_wall = east.PlaceOnTop(/turf/closed/wall/material)
	glass_wall.set_custom_materials(list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT * 2))
	var/glass_opaque = glass_wall.opacity
	glass_wall.set_custom_materials(list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 2))
	var/iron_opaque = glass_wall.opacity
	var/turf/closed/wall/material/meat_wall = glass_wall
	meat_wall.set_custom_materials(list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT * 2))
	var/meat_edible = !!meat_wall.GetComponent(/datum/component/edible)
	east.ChangeTurf(old_type, old_baseturfs)
	TEST_ASSERT(!glass_opaque, "A glass wall is opaque")
	TEST_ASSERT(iron_opaque, "A wall stayed see-through after its glass was replaced")
	TEST_ASSERT(meat_edible, "A meat wall is not edible")

/// AQUILA - BeeStation/BeeStation-Hornet#10703: mięso, Arkuszomistrz 2000 i twarde materiały w autolacie
/datum/unit_test/aquila_basemats_meat

/datum/unit_test/aquila_basemats_meat/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)

	var/obj/item/stack/sheet/meat/meat = allocate(/obj/item/stack/sheet/meat, start, 5, FALSE)
	TEST_ASSERT(meat.GetComponent(/datum/component/edible), "A meat sheet is not edible")

	var/obj/machinery/sheetifier/sheetifier = allocate(/obj/machinery/sheetifier, east)
	var/datum/component/material_container/container = sheetifier.GetComponent(/datum/component/material_container)
	var/obj/item/food/meat/slab/slab = allocate(/obj/item/food/meat/slab, east)
	TEST_ASSERT(container.insert_item(slab), "The sheetifier did not take a meat slab")
	qdel(slab)
	sheetifier.finish_processing()
	var/obj/item/stack/sheet/meat/made = locate() in east
	TEST_ASSERT(made, "The sheetifier made no meat sheets")
	TEST_ASSERT_EQUAL(made.amount, 4, "A meat slab gave the wrong amount of meat sheets")
	qdel(made)

	var/obj/machinery/modular_fabricator/autolathe/lathe = allocate(/obj/machinery/modular_fabricator/autolathe, east)
	var/datum/component/material_container/lathe_materials = lathe.GetComponent(/datum/component/material_container)
	for(var/material_type in list(/datum/material/wood, /datum/material/meat, /datum/material/plastic, /datum/material/adamantine, /datum/material/bluespace))
		TEST_ASSERT(SSmaterials.GetMaterialRef(material_type) in lathe_materials.materials, "The autolathe does not take [material_type]")

/// AQUILA - eksport i giełda liczą stos na sztukę (u Bee custom_materials stosu razy amount dawało ilość do kwadratu)
/datum/unit_test/aquila_basemats_export

/datum/unit_test/aquila_basemats_export/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 1, start.y, start.z)

	var/obj/item/stack/sheet/mineral/gold/gold = allocate(/obj/item/stack/sheet/mineral/gold, start, 50, FALSE)
	var/datum/export/material/gold/gold_export = new
	TEST_ASSERT_EQUAL(gold_export.get_amount(gold), 50, "Exporting 50 gold sheets counts the wrong amount")
	qdel(gold_export)

	var/obj/machinery/materials_market/market = allocate(/obj/machinery/materials_market, east)
	market.machine_stat &= ~(NOPOWER|BROKEN|MAINT)
	var/mob/living/carbon/human/seller = allocate(/mob/living/carbon/human, start)
	seller.put_in_active_hand(gold)
	TEST_ASSERT(market.sell_stack(gold, seller), "The market did not buy a gold stack")
	var/obj/item/stock_block/block = locate() in market.drop_location()
	TEST_ASSERT(block, "Selling a gold stack made no stock block")
	allocated += block
	TEST_ASSERT_EQUAL(block.sheets, 50, "The stock block counts the wrong amount of sheets")

/// AQUILA - BeeStation/BeeStation-Hornet#10135: przedmiot ze szkłem bez flag materiału nie jest już przebarwiony, półprzezroczysty ani osłabiony
/datum/unit_test/aquila_basemats_no_tint

/datum/unit_test/aquila_basemats_no_tint/Run()
	var/obj/item/assembly/signaler/signaler = allocate(/obj/item/assembly/signaler)
	TEST_ASSERT(aquila_test_material_amount(signaler, /datum/material/glass), "The signaler has no glass, pick another test item")
	TEST_ASSERT_EQUAL(signaler.alpha, initial(signaler.alpha), "A glass-containing item is translucent")
	TEST_ASSERT(!signaler.color, "A glass-containing item is tinted")
	TEST_ASSERT_EQUAL(signaler.max_integrity, initial(signaler.max_integrity), "A glass-containing item lost integrity")
	TEST_ASSERT_EQUAL(signaler.name, initial(signaler.name), "An item without MATERIAL_ADD_PREFIX got a material prefix")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
