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

/// AQUILA - kuźnia amunicji: rdzeń daje liczby, powłoka efekt specjalny i odporność, koszt ćwierć na trzy czwarte
/datum/unit_test/munitions_forge_layered

/datum/unit_test/munitions_forge_layered/Run()
	var/datum/munition_material/uranium = get_munition_material(/datum/material/uranium)
	var/datum/munition_material/titanium = get_munition_material(/datum/material/titanium)
	var/datum/munition_material/layered = get_munition_layered(titanium, uranium)
	TEST_ASSERT(istype(layered, /datum/munition_material/layered), "Nie powstał uran w powłoce z tytanu")
	TEST_ASSERT(layered != get_munition_layered(uranium, titanium), "Zamiana rdzenia z powłoką daje ten sam korpus")
	TEST_ASSERT_EQUAL(layered.damage_mult, uranium.damage_mult, "Obrażenia nie biorą się z rdzenia")
	TEST_ASSERT_EQUAL(layered.armour_pen_add, uranium.armour_pen_add, "Przebicie nie bierze się z rdzenia")
	TEST_ASSERT_EQUAL(layered.speed_mult, uranium.speed_mult, "Prędkość nie bierze się z rdzenia")
	TEST_ASSERT_EQUAL(layered.integrity_mult, titanium.integrity_mult, "Odporność nie bierze się z powłoki")
	TEST_ASSERT(layered.traits[/datum/munition_trait/hardened], "Korpus nie ma efektu powłoki z tytanu")
	TEST_ASSERT(!layered.traits[/datum/munition_trait/radioactive], "Korpus ma efekt rdzenia zamiast powłoki")
	var/list/cost = layered.get_cost(MINERAL_MATERIAL_AMOUNT * 2)
	TEST_ASSERT_EQUAL(cost[/datum/material/titanium], round(MINERAL_MATERIAL_AMOUNT * 2 * titanium.sheets_mult * 0.25), "Zły koszt powłoki")
	TEST_ASSERT_EQUAL(cost[/datum/material/uranium], round(MINERAL_MATERIAL_AMOUNT * 2 * uranium.sheets_mult * 0.75), "Zły koszt rdzenia")
	TEST_ASSERT_EQUAL(get_munition_layered(uranium, uranium), uranium, "Powłoka z materiału rdzenia nie daje czystego materiału")
	TEST_ASSERT_EQUAL(get_munition_layered(null, uranium), uranium, "Brak powłoki nie daje czystego materiału")
	for(var/key in GLOB.munition_materials)
		TEST_ASSERT(GLOB.munition_materials[key] != layered, "Korpus z powłoką trafił do tabeli kuźni railguna")

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

/// AQUILA - kuźnia amunicji: odlew wybrany w oknie pieca, kucie pod młotem mechanicznym, stół montażowy i strzał z wykutego naboju
/datum/unit_test/munitions_forge_pipeline

/datum/unit_test/munitions_forge_pipeline/Run()
	var/obj/machinery/munitions_forge/arc_forge/forge = allocate(/obj/machinery/munitions_forge/arc_forge)
	forge.machine_stat &= ~NOPOWER
	var/datum/component/material_container/container = forge.get_container()
	TEST_ASSERT(container, "Piec łukowy bez silosu nie dostał własnego magazynu")
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/iron)
	container.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 20, /datum/material/copper)

	// koszt rdzenia w powłoce w oknie pieca: oba materiały
	forge.selected_product = /obj/item/munition_part/body/casings/c9mm
	forge.selected_material = get_munition_material(/datum/material/iron)
	forge.selected_coating = get_munition_material(/datum/material/copper)
	var/list/layered_cost = forge.current_cost()
	TEST_ASSERT(layered_cost[/datum/material/iron] && layered_cost[/datum/material/copper], "Rdzeń w powłoce w oknie pieca nie kosztuje obu materiałów")
	forge.selected_coating = null
	// typ bazowy grupy nie jest wyrobem (korpus bez product_path): piec go nie odlewa i nie bierze materiału
	TEST_ASSERT(!aq_forge_is_product(/obj/item/munition_part/body/casings), "Typ bazowy łusek przechodzi jako wyrób pieca")
	forge.selected_product = /obj/item/munition_part/body/casings
	var/iron_before = container.get_material_amount(/datum/material/iron)
	TEST_ASSERT(!forge.prepare_cast(null), "Piec przygotował odlew typu bazowego łusek")
	TEST_ASSERT_EQUAL(container.get_material_amount(/datum/material/iron), iron_before, "Odrzucony odlew zużył żelazo")
	forge.selected_product = /obj/item/munition_part/body/casings/c9mm
	TEST_ASSERT(aq_forge_product_available(/obj/item/munition_part/fuze/primer), "Spłonki nie są dostępne w piecu")
	TEST_ASSERT(GLOB.aq_forge_products["Wkładki do pancerza"], "W oknie pieca nie ma wkładek do pancerza")

	// odlew zapalnika wybranego w oknie: bez wyboru materiału
	forge.selected_product = /obj/item/munition_part/fuze/primer
	forge.selected_quality = /datum/munition_quality
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

	// młot mechaniczny: klasę I kuje sam, bez minigry
	var/mob/living/carbon/human/smith = allocate(/mob/living/carbon/human)
	var/obj/machinery/munitions_forge/anvil/anvil = allocate(/obj/machinery/munitions_forge/anvil, locate(forge.x + 4, forge.y, forge.z))
	anvil.machine_stat &= ~NOPOWER
	primer.forceMove(anvil)
	anvil.working_part = primer
	TEST_ASSERT(anvil.start_operation(smith) && !anvil.game, "Młot nie zaczął sam kuć klasy I")
	anvil.complete_operation(smith)
	anvil.operating = FALSE
	TEST_ASSERT(primer.is_finished(), "Młot nie wykuł spłonek")
	TEST_ASSERT_EQUAL(primer.quality, get_munition_quality(/datum/munition_quality), "Automat dał inną klasę niż I")

	// wyższa klasa: automat jej nie wykuje, potrzebne kucie ręczne (bez klienta okno się nie otworzy)
	var/obj/item/munition_part/fuze/impact/impact = allocate(/obj/item/munition_part/fuze/impact)
	impact.cast_finished(get_munition_quality(/datum/munition_quality/enhanced))
	impact.forceMove(anvil)
	anvil.working_part = impact
	TEST_ASSERT(!anvil.start_operation(smith) && !impact.is_finished(), "Młot sam wykuł klasę III")
	var/datum/munitions_anvil_game/game = new(anvil, smith, impact)
	anvil.game = game
	TEST_ASSERT(length(game.notes) >= 4, "Za mało nut")
	anvil.game = game
	for(var/i in 1 to length(game.notes))
		game.results["[i]"] = (i % 2 == 0)
	game.finish()
	TEST_ASSERT(impact.is_finished(), "Kucie ręczne nie wykuło zapalnika")
	TEST_ASSERT(!anvil.game && !anvil.operating, "Młot został zajęty po kuciu")
	TEST_ASSERT(impact.quality.level < 2, "Pudła nie obniżyły klasy")

	// korpus bez UI wyboru materiału
	var/datum/munition_quality/quality = get_munition_quality(/datum/munition_quality)
	var/obj/item/munition_part/body/casings/c9mm/body = allocate(/obj/item/munition_part/body/casings/c9mm)
	body.set_material(get_munition_material(/datum/material/uranium))
	body.cast_finished(quality)
	body.hammer_time = 0

	var/obj/machinery/munitions_forge/assembly_bench/bench = allocate(/obj/machinery/munitions_forge/assembly_bench, locate(forge.x + 4, forge.y + 1, forge.z))
	for(var/obj/item/munition_part/part in list(body, primer))
		part.forceMove(bench)
	bench.body = body
	bench.fuze = primer
	bench.complete_operation(null)
	var/obj/item/ammo_box/c9mm/box = locate() in get_turf(bench)
	TEST_ASSERT(box, "Stół nie wydał pudełka 9mm")
	TEST_ASSERT(QDELETED(body) && QDELETED(primer), "Stół nie zużył części")
	TEST_ASSERT(length(box.stored_ammo), "Pudełko jest puste")
	var/obj/item/ammo_casing/casing = box.stored_ammo[1]
	TEST_ASSERT(casing.GetComponent(/datum/component/forged_munition), "Nabój nie dostał właściwości z kuźni")
	TEST_ASSERT(forged_munition_value(box) > 0, "Wykute pudełko nic nie jest warte w eksporcie")

	// strzał: pocisk przejmuje uran (×1,2, +15); amunicja ręczna nie ma typów pocisku
	var/obj/item/projectile/base_bullet = new casing.projectile_type(null)
	var/base_damage = base_bullet.damage
	var/base_pen = base_bullet.armour_penetration
	qdel(base_bullet)
	casing.ready_proj(smith, smith)
	TEST_ASSERT(casing.BB, "Nabój nie ma pocisku")
	TEST_ASSERT_EQUAL(casing.BB.damage, round(base_damage * 1.2, 0.1), "Złe obrażenia wykutego pocisku")
	TEST_ASSERT_EQUAL(casing.BB.armour_penetration, base_pen + 15, "Złe przebicie wykutego pocisku")
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

/// AQUILA - kuźnia amunicji: głowica z właściwościami kuźni (sprzed reworku) przekazuje je torpedzie, a torpeda pociskowi
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
	// diament ×0,9 i +30, klasa V ×1,2, HE ×1,3 i -15
	TEST_ASSERT_EQUAL(P.damage, round(base_damage * 0.9 * 1.2 * 1.3, 0.1), "Złe obrażenia torpedy")
	TEST_ASSERT_EQUAL(P.armour_penetration, base_pen + 15, "Złe przebicie torpedy")
	TEST_ASSERT_EQUAL(P.max_integrity, round(base_integrity * 1.2 * 1.2), "Zła wytrzymałość torpedy")

/// AQUILA - kuźnia amunicji: korpus Gaussa daje pół stojaka pocisków, a eksport i galwanizer liczą koszt na sztukę
/datum/unit_test/munitions_forge_gauss_batch

/datum/unit_test/munitions_forge_gauss_batch/Run()
	var/obj/item/munition_part/body/shell/gauss/body = allocate(/obj/item/munition_part/body/shell/gauss)
	body.set_material(get_munition_material(/datum/material/iron))
	var/datum/munition_quality/quality = get_munition_quality(/datum/munition_quality/masterwork)
	var/list/products = body.create_product(run_loc_floor_bottom_left, quality)
	TEST_ASSERT_EQUAL(length(products), 6, "Z korpusu Gaussa nie powstało 6 pocisków")
	var/batch_value = 0
	for(var/obj/item/ship_weapon/ammunition/gauss/shell as anything in products)
		allocated += shell
		TEST_ASSERT(istype(shell), "Wyrób korpusu Gaussa to nie pocisk Gaussa")
		TEST_ASSERT(shell.GetComponent(/datum/component/forged_munition), "Pocisk z partii nie ma właściwości z kuźni")
		batch_value += forged_munition_value(shell)
	TEST_ASSERT(forged_munition_value(products[1]) > 0, "Pocisk z partii nic nie jest wart w eksporcie")
	// Cała partia jest warta tyle co surowce i jedna premia za robotę (nie sześć); każdy pocisk zaokrągla cenę osobno
	var/obj/item/first_shell = products[1]
	var/datum/component/forged_munition/forged = first_shell.GetComponent(/datum/component/forged_munition)
	var/expected = forged_product_value(forged, /obj/item/munition_part/body/shell/gauss) * 6
	TEST_ASSERT(abs(batch_value - expected) <= 4, "Partia Gaussa jest warta [batch_value] kr, a powinna około [expected] kr")
	// galwanizer pokrywa jeden pocisk, a nie całą partię: pół arkusza na pocisk
	var/obj/machinery/munitions_forge/electroplater/plater = allocate(/obj/machinery/munitions_forge/electroplater)
	TEST_ASSERT_EQUAL(plater.plating_amount(products[1]), initial(body.material_amount) / 6 * 0.5 * plater.efficiency, "Galwanizer liczy pocisk Gaussa jak całą partię")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
