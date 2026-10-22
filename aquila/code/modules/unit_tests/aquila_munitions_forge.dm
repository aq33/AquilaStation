// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - kuźnia amunicji: tabela materiałów obejmuje wszystkie materiały kuźni railguna i każdy wpis wskazuje prawdziwy materiał
/datum/unit_test/munitions_forge_materials

/datum/unit_test/munitions_forge_materials/Run()
	var/list/seen_railgun_names = list()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		TEST_ASSERT(getmaterialref(M.material_type), "[M.type] wskazuje nieistniejący materiał [M.material_type]")
		TEST_ASSERT(M.railgun_name, "[M.type] nie ma nazwy dla kuźni railguna")
		TEST_ASSERT(!seen_railgun_names[M.railgun_name], "Nazwa [M.railgun_name] powtarza się w tabeli")
		seen_railgun_names[M.railgun_name] = TRUE
	for(var/railgun_name in list("Iron", "Silver", "Gold", "Diamond", "Uranium", "Plasma", "Bluespace", "Bananium", "Titanium", "Copper"))
		TEST_ASSERT(get_munition_material_by_railgun_name(railgun_name), "Kuźnia railguna nie znajdzie materiału [railgun_name]")
	var/datum/munition_material/iron = get_munition_material(/datum/material/iron)
	TEST_ASSERT_EQUAL(iron.damage_mult, 1, "Żelazo ma być poziomem zwykłej amunicji")

/// AQUILA - kuźnia amunicji: stop to średnia liczb, cechy obu składników ze słabszą siłą, koszt po połowie
/datum/unit_test/munitions_forge_alloy

/datum/unit_test/munitions_forge_alloy/Run()
	var/datum/munition_material/uranium = get_munition_material(/datum/material/uranium)
	var/datum/munition_material/titanium = get_munition_material(/datum/material/titanium)
	var/datum/munition_material/alloy = get_munition_alloy(uranium, titanium)
	TEST_ASSERT(alloy, "Nie powstał stop uranu z tytanem")
	TEST_ASSERT_EQUAL(alloy, get_munition_alloy(titanium, uranium), "Kolejność składników zmienia stop")
	TEST_ASSERT_EQUAL(alloy.damage_mult, round((uranium.damage_mult + titanium.damage_mult) / 2, 0.01), "Zły mnożnik obrażeń stopu")
	TEST_ASSERT_EQUAL(alloy.armour_pen_add, round((uranium.armour_pen_add + titanium.armour_pen_add) / 2), "Złe przebicie stopu")
	var/datum/munition_trait/radioactive/rad = alloy.traits[/datum/munition_trait/radioactive]
	TEST_ASSERT(rad, "Stop zgubił cechę uranu")
	TEST_ASSERT(rad.power < 1, "Cecha w stopie ma pełną siłę")
	var/list/cost = alloy.get_cost(MINERAL_MATERIAL_AMOUNT * 2)
	TEST_ASSERT_EQUAL(cost[/datum/material/uranium], round(MINERAL_MATERIAL_AMOUNT * uranium.sheets_mult), "Zły koszt uranu w stopie")
	TEST_ASSERT_EQUAL(cost[/datum/material/titanium], round(MINERAL_MATERIAL_AMOUNT * titanium.sheets_mult), "Zły koszt tytanu w stopie")
	TEST_ASSERT(!get_munition_alloy(uranium, uranium), "Powstał stop materiału z samym sobą")
	for(var/key in GLOB.munition_materials)
		TEST_ASSERT(GLOB.munition_materials[key] != alloy, "Stop trafił do tabeli kuźni railguna")

/// AQUILA - kuźnia amunicji: klasa spada od 90% celności, co 15% o jedną
/datum/unit_test/munitions_forge_anvil_quality

/datum/unit_test/munitions_forge_anvil_quality/Run()
	TEST_ASSERT_EQUAL(anvil_quality_drop(1), 0, "Bez pudła klasa spadła")
	TEST_ASSERT_EQUAL(anvil_quality_drop(0.9), 0, "Przy 90% klasa spadła")
	TEST_ASSERT_EQUAL(anvil_quality_drop(0.8), 1, "Przy 80% klasa ma spaść o jeden")
	TEST_ASSERT_EQUAL(anvil_quality_drop(0.5), 3, "Przy 50% klasa ma spaść o trzy")
	var/datum/munition_quality/top = get_munition_quality(/datum/munition_quality/masterwork)
	TEST_ASSERT_EQUAL(lower_munition_quality(top, 10), get_munition_quality(/datum/munition_quality), "Klasa spadła poniżej I")
	TEST_ASSERT_EQUAL(lower_munition_quality(top, 1), get_munition_quality(/datum/munition_quality/superior), "Klasa V o jeden w dół to nie IV")

/// AQUILA - kuźnia amunicji: odlew w piecu łukowym, kucie na kowadle, stół montażowy i strzał z wykutego naboju
/datum/unit_test/munitions_forge_pipeline

/datum/unit_test/munitions_forge_pipeline/Run()
	var/obj/machinery/munitions_forge/arc_forge/forge = allocate(/obj/machinery/munitions_forge/arc_forge)
	forge.machine_stat &= ~NOPOWER
	var/datum/component/material_container/container = forge.get_container()
	TEST_ASSERT(container, "Piec łukowy bez silosu nie dostał własnego magazynu")
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/iron)
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/copper)

	// odlew zapalnika: forma bez wyboru materiału
	var/obj/item/munition_cast/fuze/cast = allocate(/obj/item/munition_cast/fuze)
	cast.selected_product = /obj/item/munition_part/fuze/primer
	cast.forceMove(forge)
	forge.cast = cast
	var/copper_before = container.get_material_amount(/datum/material/copper)
	TEST_ASSERT(forge.start_operation(null), "Piec nie zaczął odlewu")
	TEST_ASSERT(container.get_material_amount(/datum/material/copper) < copper_before, "Odlew nie zużył miedzi")
	forge.complete_operation(null)
	forge.operating = FALSE
	var/obj/item/munition_part/fuze/primer/primer = forge.produced_part
	TEST_ASSERT(istype(primer), "Piec nie wylał spłonek")
	TEST_ASSERT(primer.forge_heat > 0, "Świeży odlew nie jest gorący")

	// dogrzewanie w piecu
	forge.produced_part = null
	primer.forge_heat = 1
	forge.working_part = primer
	TEST_ASSERT(forge.start_operation(null), "Piec nie zaczął dogrzewać")
	forge.complete_operation(null)
	forge.operating = FALSE
	TEST_ASSERT(primer.forge_heat > 1, "Piec nie dogrzał części")
	forge.working_part = null

	// kowadło: wszystkie nuty trafione, klasa zostaje
	var/mob/living/carbon/human/smith = allocate(/mob/living/carbon/human)
	var/obj/machinery/munitions_forge/anvil/anvil = allocate(/obj/machinery/munitions_forge/anvil, locate(forge.x + 4, forge.y, forge.z))
	primer.forceMove(anvil)
	anvil.working_part = primer
	var/datum/munitions_anvil_game/game = new(anvil, smith, primer)
	anvil.game = game
	TEST_ASSERT(length(game.notes) >= 4, "Za mało nut")
	for(var/i in 1 to length(game.notes))
		game.results["[i]"] = TRUE
	game.finish()
	TEST_ASSERT(primer.is_finished(), "Kowadło nie wykuło spłonek")
	TEST_ASSERT_EQUAL(primer.quality, get_munition_quality(/datum/munition_quality), "Bez pudła zmieniła się klasa")
	TEST_ASSERT(!anvil.game && !anvil.operating, "Kowadło zostało zajęte po kuciu")

	// kowadło: połowa pudeł z klasy III daje klasę niższą
	var/obj/item/munition_part/filler/ap/filler = allocate(/obj/item/munition_part/filler/ap)
	filler.cast_finished(get_munition_quality(/datum/munition_quality/enhanced))
	filler.forceMove(anvil)
	anvil.working_part = filler
	game = new(anvil, smith, filler)
	anvil.game = game
	for(var/i in 1 to length(game.notes))
		game.results["[i]"] = (i % 2 == 0)
	game.finish()
	TEST_ASSERT(filler.is_finished(), "Kowadło nie wykuło wypełnienia")
	TEST_ASSERT(filler.quality.level < 2, "Pudła nie obniżyły klasy")
	filler.quality = get_munition_quality(/datum/munition_quality)

	// korpus bez UI wyboru materiału
	var/datum/munition_quality/quality = get_munition_quality(/datum/munition_quality)
	var/obj/item/munition_part/body/casings/c9mm/body = allocate(/obj/item/munition_part/body/casings/c9mm)
	body.set_material(get_munition_material(/datum/material/uranium))
	body.cast_finished(quality)
	body.hammer_time = 0

	var/obj/machinery/munitions_forge/assembly_bench/bench = allocate(/obj/machinery/munitions_forge/assembly_bench, locate(forge.x + 4, forge.y + 1, forge.z))
	for(var/obj/item/munition_part/part in list(body, filler, primer))
		part.forceMove(bench)
	bench.body = body
	bench.filler = filler
	bench.fuze = primer
	bench.complete_operation(null)
	var/obj/item/ammo_box/c9mm/box = locate() in get_turf(bench)
	TEST_ASSERT(box, "Stół nie wydał pudełka 9mm")
	TEST_ASSERT(QDELETED(body) && QDELETED(primer) && QDELETED(filler), "Stół nie zużył części")
	TEST_ASSERT(length(box.stored_ammo), "Pudełko jest puste")
	var/obj/item/ammo_casing/casing = box.stored_ammo[1]
	TEST_ASSERT(casing.GetComponent(/datum/component/forged_munition), "Nabój nie dostał właściwości z kuźni")
	TEST_ASSERT(forged_munition_value(box) > 0, "Wykute pudełko nic nie jest warte w eksporcie")

	// strzał: pocisk przejmuje uran (×1,2, +15) i rdzeń AP (×0,9, +20)
	var/obj/item/projectile/base_bullet = new casing.projectile_type(null)
	var/base_damage = base_bullet.damage
	var/base_pen = base_bullet.armour_penetration
	qdel(base_bullet)
	casing.ready_proj(smith, smith)
	TEST_ASSERT(casing.BB, "Nabój nie ma pocisku")
	TEST_ASSERT_EQUAL(casing.BB.damage, round(base_damage * 1.2 * 0.9, 0.1), "Złe obrażenia wykutego pocisku")
	TEST_ASSERT_EQUAL(casing.BB.armour_penetration, base_pen + 35, "Złe przebicie wykutego pocisku")
	var/datum/component/forged_munition/bullet_forged = casing.BB.GetComponent(/datum/component/forged_munition)
	TEST_ASSERT(bullet_forged?.get_trait(/datum/munition_trait/radioactive), "Pocisk zgubił cechę uranu")

/// AQUILA - kuźnia amunicji: galwanizer pokrywa zwykłe pudełko materiałem z pieca łukowego
/datum/unit_test/munitions_forge_electroplater

/datum/unit_test/munitions_forge_electroplater/Run()
	var/obj/machinery/munitions_forge/arc_forge/forge = allocate(/obj/machinery/munitions_forge/arc_forge)
	var/datum/component/material_container/container = forge.get_container()
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/silver)
	var/obj/machinery/munitions_forge/electroplater/plater = allocate(/obj/machinery/munitions_forge/electroplater, locate(forge.x + 4, forge.y, forge.z))
	plater.machine_stat &= ~NOPOWER
	var/obj/item/ammo_box/c9mm/box = allocate(/obj/item/ammo_box/c9mm)
	TEST_ASSERT_EQUAL(forged_munition_value(box), 0, "Zwykłe pudełko ma cenę wyrobu z kuźni")
	box.forceMove(plater)
	plater.plated_item = box
	plater.pending_material = get_munition_material(/datum/material/silver)
	var/silver_before = container.get_material_amount(/datum/material/silver)
	TEST_ASSERT(plater.start_operation(null), "Galwanizer nie zaczął pracy")
	TEST_ASSERT(container.get_material_amount(/datum/material/silver) < silver_before, "Galwanizer nie zużył srebra")
	plater.complete_operation(null)
	var/datum/component/forged_munition/forged = get_forged_munition(box)
	TEST_ASSERT(forged, "Pudełko nie dostało właściwości")
	TEST_ASSERT(forged.galvanized, "Pokryte pudełko nie jest oznaczone jako galwanizowane")
	TEST_ASSERT_EQUAL(forged.quality, get_munition_quality(/datum/munition_quality), "Galwanizacja dała klasę wyższą niż I")
	TEST_ASSERT(forged.get_trait(/datum/munition_trait/holy), "Pokryte pudełko nie ma cechy srebra")
	TEST_ASSERT(!plater.plated_item, "Pudełko zostało w galwanizerze")

/// AQUILA - kuźnia amunicji: głowica przekazuje właściwości torpedzie, a torpeda pociskowi na overmapie
/datum/unit_test/munitions_forge_warhead

/datum/unit_test/munitions_forge_warhead/Run()
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/warhead = allocate(/obj/item/ship_weapon/parts/missile/warhead/torpedo)
	warhead.AddComponent(/datum/component/forged_munition, get_munition_material(/datum/material/diamond), get_munition_quality(/datum/munition_quality/masterwork), get_munition_filler(/datum/munition_filler/he))
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo = allocate(warhead.build_path)
	transfer_forged_munition(warhead, torpedo)
	TEST_ASSERT(torpedo.GetComponent(/datum/component/forged_munition), "Torpeda nie przejęła właściwości głowicy")
	var/obj/item/projectile/P = allocate(torpedo.projectile_type)
	var/base_damage = P.damage
	var/base_pen = P.armour_penetration
	var/base_integrity = P.max_integrity
	transfer_forged_munition(torpedo, P)
	// diament ×0,9 i +30, klasa V ×1,2, HE ×1,15 i -5
	TEST_ASSERT_EQUAL(P.damage, round(base_damage * 0.9 * 1.2 * 1.15, 0.1), "Złe obrażenia torpedy")
	TEST_ASSERT_EQUAL(P.armour_penetration, base_pen + 25, "Złe przebicie torpedy")
	TEST_ASSERT_EQUAL(P.max_integrity, round(base_integrity * 1.2 * 1.2), "Zła wytrzymałość torpedy")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
