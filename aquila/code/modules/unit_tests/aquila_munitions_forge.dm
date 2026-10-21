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

/// AQUILA - kuźnia amunicji: odlew w basenie, młot, monter i strzał z wykutego naboju
/datum/unit_test/munitions_forge_pipeline

/datum/unit_test/munitions_forge_pipeline/Run()
	var/obj/machinery/munitions_forge/crucible/crucible = allocate(/obj/machinery/munitions_forge/crucible)
	var/datum/component/material_container/container = crucible.get_container()
	TEST_ASSERT(container, "Tygiel bez silosu nie dostał własnego magazynu")
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/iron)
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/copper)

	// odlew zapalnika: forma bez wyboru materiału
	var/obj/machinery/munitions_forge/basin/basin = allocate(/obj/machinery/munitions_forge/basin, locate(crucible.x + 3, crucible.y, crucible.z))
	basin.machine_stat &= ~NOPOWER
	var/obj/item/munition_cast/fuze/cast = allocate(/obj/item/munition_cast/fuze)
	cast.selected_product = /obj/item/munition_part/fuze/primer
	cast.forceMove(basin)
	basin.cast = cast
	var/copper_before = container.get_material_amount(/datum/material/copper)
	TEST_ASSERT(basin.start_operation(null), "Basen nie zaczął odlewu")
	TEST_ASSERT(container.get_material_amount(/datum/material/copper) < copper_before, "Odlew nie zużył miedzi")
	basin.complete_operation(null)
	var/obj/item/munition_part/fuze/primer/primer = basin.produced_part
	TEST_ASSERT(istype(primer), "Basen nie wylał spłonek")
	TEST_ASSERT(primer.forge_heat > 0, "Świeży odlew nie jest gorący")

	// młot: kuje tylko gorące części, aż do końca
	var/obj/machinery/munitions_forge/hammer/hammer = allocate(/obj/machinery/munitions_forge/hammer, locate(crucible.x, crucible.y + 3, crucible.z))
	primer.forceMove(hammer)
	hammer.working_part = primer
	while(!primer.is_finished())
		hammer.complete_operation(null)
	TEST_ASSERT(primer.is_finished(), "Młot nie dokończył spłonek")

	// korpus i wypełnienie bez UI wyboru materiału
	var/datum/munition_quality/quality = get_munition_quality(/datum/munition_quality)
	var/obj/item/munition_part/body/casings/c9mm/body = allocate(/obj/item/munition_part/body/casings/c9mm)
	body.set_material(get_munition_material(/datum/material/uranium))
	body.cast_finished(quality)
	body.hammer_time = 0
	var/obj/item/munition_part/filler/ap/filler = allocate(/obj/item/munition_part/filler/ap)
	filler.cast_finished(quality)
	filler.hammer_time = 0

	var/obj/machinery/munitions_forge/assembler/assembler = allocate(/obj/machinery/munitions_forge/assembler, locate(crucible.x + 3, crucible.y + 1, crucible.z))
	for(var/obj/item/munition_part/part in list(body, filler, primer))
		part.forceMove(assembler)
	hammer.working_part = null
	assembler.body = body
	assembler.filler = filler
	assembler.fuze = primer
	assembler.complete_operation(null)
	var/obj/item/ammo_box/c9mm/box = locate() in get_turf(assembler)
	TEST_ASSERT(box, "Monter nie wydał pudełka 9mm")
	TEST_ASSERT(QDELETED(body) && QDELETED(primer) && QDELETED(filler), "Monter nie zużył części")
	TEST_ASSERT(length(box.stored_ammo), "Pudełko jest puste")
	var/obj/item/ammo_casing/casing = box.stored_ammo[1]
	TEST_ASSERT(casing.GetComponent(/datum/component/forged_munition), "Nabój nie dostał właściwości z kuźni")

	// strzał: pocisk przejmuje uran (×1,2, +15) i rdzeń AP (×0,9, +20)
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human)
	var/obj/item/projectile/base_bullet = new casing.projectile_type(null)
	var/base_damage = base_bullet.damage
	var/base_pen = base_bullet.armour_penetration
	qdel(base_bullet)
	casing.ready_proj(shooter, shooter)
	TEST_ASSERT(casing.BB, "Nabój nie ma pocisku")
	TEST_ASSERT_EQUAL(casing.BB.damage, round(base_damage * 1.2 * 0.9, 0.1), "Złe obrażenia wykutego pocisku")
	TEST_ASSERT_EQUAL(casing.BB.armour_penetration, base_pen + 35, "Złe przebicie wykutego pocisku")

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
