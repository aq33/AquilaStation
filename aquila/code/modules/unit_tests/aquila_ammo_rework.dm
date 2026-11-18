// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - rework amunicji: pocisk artylerii z kuźni kosztuje tyle co dawny przepis protolathe, a projekt zniknął z protolathe
/datum/unit_test/ammo_rework_artillery_cost

/datum/unit_test/ammo_rework_artillery_cost/Run()
	var/obj/machinery/munitions_forge/arc_forge/forge = allocate(/obj/machinery/munitions_forge/arc_forge)
	TEST_ASSERT_EQUAL(forge.efficiency, 1, "Piec na częściach T1 ma inną sprawność niż 1")
	forge.selected_product = /obj/item/munition_part/body/shell/naval
	forge.selected_material = get_munition_material(/datum/material/iron)
	forge.selected_coating = null
	forge.selected_quality = /datum/munition_quality
	var/list/cost = forge.current_cost()
	TEST_ASSERT_EQUAL(cost[/datum/material/iron], 10000, "Żelazo w pocisku artylerii klasy I")
	TEST_ASSERT_EQUAL(cost[/datum/material/titanium], 5000, "Tytan w pocisku artylerii klasy I")
	TEST_ASSERT_EQUAL(cost[/datum/material/copper], 500, "Miedź w pocisku artylerii klasy I")
	// pięć łusek burtowych kosztuje tyle co pięć łusek z dawnego protolathe
	forge.selected_product = /obj/item/munition_part/body/shell/broadside
	cost = forge.current_cost()
	TEST_ASSERT_EQUAL(cost[/datum/material/iron], 2500, "Żelazo w pięciu łuskach burtowych")
	TEST_ASSERT_EQUAL(cost[/datum/material/titanium], 7500, "Tytan w pięciu łuskach burtowych")
	// wyrób z protolathe wymaga tego samego badania
	TEST_ASSERT_EQUAL(aq_forge_product_available(/obj/item/munition_part/body/shell/naval), !!SSresearch.science_tech?.researched_nodes["adv_ballistics"], "Pocisk artylerii w piecu nie zależy od Zaawansowanej balistyki")
	var/datum/techweb_node/node = SSresearch.techweb_node_by_id("adv_ballistics")
	TEST_ASSERT(!("naval_shell" in node.design_ids), "Pocisk artylerii został w protolathe")
	TEST_ASSERT(!("broadside_casing" in node.design_ids), "Łuska burtowa została w protolathe")
	TEST_ASSERT("powder_bag" in node.design_ids, "Worek prochu zniknął z protolathe")

/// AQUILA - rework amunicji: typ AP i materiał rdzenia i powłoki działają na pocisk artylerii po strzale
/datum/unit_test/ammo_rework_shell_type

/datum/unit_test/ammo_rework_shell_type/Run()
	var/obj/item/munition_part/body/shell/naval/body = allocate(/obj/item/munition_part/body/shell/naval)
	body.set_material(get_munition_layered(get_munition_material(/datum/material/silver), get_munition_material(/datum/material/uranium)))
	body.shell_type = get_munition_filler(/datum/munition_filler/ap)
	body.cast_finished(get_munition_quality(/datum/munition_quality))
	var/list/products = body.create_product(run_loc_floor_bottom_left, get_munition_quality(/datum/munition_quality))
	var/obj/item/ship_weapon/ammunition/naval_artillery/shell = products[1]
	allocated += shell
	TEST_ASSERT(istype(shell), "Korpus artylerii nie dał pocisku")
	var/obj/item/projectile/P = allocate(shell.projectile_type)
	var/base_damage = P.damage
	var/base_pen = P.armour_penetration
	transfer_forged_munition(shell, P)
	// rdzeń uran ×1,2 i +15, typ AP ×0,85 i +25
	TEST_ASSERT_EQUAL(P.damage, round(base_damage * 1.2 * 0.85, 0.1), "Złe obrażenia pocisku AP z uranu")
	TEST_ASSERT_EQUAL(P.armour_penetration, base_pen + 40, "Złe przebicie pocisku AP z uranu")
	var/datum/component/forged_munition/F = P.GetComponent(/datum/component/forged_munition)
	TEST_ASSERT(F.get_trait(/datum/munition_trait/emp) && F.get_trait(/datum/munition_trait/holy), "Pocisk nie ma efektu powłoki ze srebra")
	TEST_ASSERT(!F.get_trait(/datum/munition_trait/radioactive), "Pocisk ma efekt rdzenia zamiast powłoki")
	// miedź daje ten sam impuls EMP co srebro, ale z połową siły
	var/datum/munition_material/copper = get_munition_material(/datum/material/copper)
	var/datum/munition_trait/emp/weak/weak_emp = copper.traits[/datum/munition_trait/emp/weak]
	TEST_ASSERT_EQUAL(weak_emp?.power, 0.5, "Słaby impuls EMP miedzi ma złą siłę")
	// HE ma najwięcej obrażeń, ale ujemne przebicie
	var/datum/munition_filler/he = get_munition_filler(/datum/munition_filler/he)
	var/datum/munition_filler/ap = get_munition_filler(/datum/munition_filler/ap)
	var/datum/munition_filler/aphe = get_munition_filler(/datum/munition_filler/aphe)
	TEST_ASSERT(he.damage_mult > aphe.damage_mult && aphe.damage_mult > ap.damage_mult, "Kolejność obrażeń HE > APHE > AP się nie zgadza")
	TEST_ASSERT(ap.armour_pen_add > aphe.armour_pen_add && aphe.armour_pen_add > 0 && he.armour_pen_add < 0, "Kolejność przebicia AP > APHE > 0 > HE się nie zgadza")

/// AQUILA - rework amunicji: fabryczne pociski z cargo mają typ, nie mają klasy ani kary klasy I i nie sprzedają się jak wyrób kuźni
/datum/unit_test/ammo_rework_factory

/datum/unit_test/ammo_rework_factory/Run()
	var/obj/item/ship_weapon/ammunition/naval_artillery/factory/he/shell = allocate(/obj/item/ship_weapon/ammunition/naval_artillery/factory/he)
	var/datum/component/forged_munition/F = shell.GetComponent(/datum/component/forged_munition)
	TEST_ASSERT(F?.factory, "Fabryczny pocisk nie jest oznaczony jako fabryczny")
	TEST_ASSERT_EQUAL(F.filler, get_munition_filler(/datum/munition_filler/he), "Fabryczny pocisk HE ma inny typ")
	TEST_ASSERT(!aq_is_rough_munition(shell), "Fabryczny pocisk ma karę klasy I")
	TEST_ASSERT(!findtext(shell.name, "klasa"), "Fabryczny pocisk ma klasę w nazwie: [shell.name]")
	TEST_ASSERT_EQUAL(forged_munition_value(shell), 0, "Fabryczny pocisk sprzedaje się jak wyrób kuźni")
	var/obj/item/ship_weapon/parts/broadside_casing/factory/ap/casing = allocate(/obj/item/ship_weapon/parts/broadside_casing/factory/ap)
	var/datum/component/forged_munition/casing_forged = casing.GetComponent(/datum/component/forged_munition)
	TEST_ASSERT_EQUAL(casing_forged?.filler, get_munition_filler(/datum/munition_filler/ap), "Fabryczna łuska AP ma inny typ")

/// AQUILA - rework amunicji: pakowarka burtówek przenosi właściwości każdej łuski na jej pocisk
/datum/unit_test/ammo_rework_packer

/datum/unit_test/ammo_rework_packer/Run()
	var/obj/machinery/broadside_shell_packer/packer = allocate(/obj/machinery/broadside_shell_packer)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/ship_weapon/parts/broadside_casing/forged_casing = allocate(/obj/item/ship_weapon/parts/broadside_casing)
	apply_forged_munition(forged_casing, get_munition_material(/datum/material/uranium), get_munition_quality(/datum/munition_quality/improved), get_munition_filler(/datum/munition_filler/he))
	var/obj/item/ship_weapon/parts/broadside_casing/plain_casing = allocate(/obj/item/ship_weapon/parts/broadside_casing)
	TEST_ASSERT(packer.load(forged_casing, user), "Pakowarka nie przyjęła wykutej łuski")
	TEST_ASSERT(packer.load(plain_casing, user), "Pakowarka nie przyjęła zwykłej łuski")
	var/obj/item/ship_weapon/ammunition/broadside_shell/first = allocate(/obj/item/ship_weapon/ammunition/broadside_shell)
	var/obj/item/ship_weapon/ammunition/broadside_shell/second = allocate(/obj/item/ship_weapon/ammunition/broadside_shell)
	packer.aq_apply_casing_munition(first, 1)
	packer.aq_apply_casing_munition(second, 2)
	var/datum/component/forged_munition/F = first.GetComponent(/datum/component/forged_munition)
	TEST_ASSERT(F, "Pocisk z wykutej łuski nie dostał właściwości")
	TEST_ASSERT_EQUAL(F.material, get_munition_material(/datum/material/uranium), "Pocisk ma inny materiał niż łuska")
	TEST_ASSERT_EQUAL(F.quality, get_munition_quality(/datum/munition_quality/improved), "Pocisk ma inną klasę niż łuska")
	TEST_ASSERT_EQUAL(F.filler, get_munition_filler(/datum/munition_filler/he), "Pocisk ma inny typ niż łuska")
	TEST_ASSERT(!second.GetComponent(/datum/component/forged_munition), "Pocisk ze zwykłej łuski dostał właściwości z kuźni")
	packer.reset()
	TEST_ASSERT(!LAZYLEN(packer.aq_casing_munitions), "Pakowarka pamięta łuski po spakowaniu")

/// AQUILA - rework amunicji: część fabryczna wychodzi z pieca od razu gotowa, w całej partii
/datum/unit_test/ammo_rework_simple_cast

/datum/unit_test/ammo_rework_simple_cast/Run()
	var/obj/machinery/munitions_forge/arc_forge/forge = allocate(/obj/machinery/munitions_forge/arc_forge)
	var/turf/drop = forge.drop_location()
	var/before = 0
	for(var/obj/item/ship_weapon/parts/broadside_load/load in drop)
		before++
	forge.pending_product = /obj/item/munition_part/simple/broadside_load
	forge.complete_operation(null)
	var/after = 0
	for(var/obj/item/ship_weapon/parts/broadside_load/load in drop)
		after++
		if(!(load in allocated))
			allocated += load
	TEST_ASSERT_EQUAL(after - before, 5, "Piec nie wyrzucił pięciu ładunków burtowych")
	TEST_ASSERT(!forge.produced_part && !forge.pending_product, "Część fabryczna została w piecu")

/// AQUILA - rework amunicji: podgląd kuźni railguna liczy tym samym wzorem co strzał
/datum/unit_test/ammo_rework_railgun_preview

/datum/unit_test/ammo_rework_railgun_preview/Run()
	var/datum/munition_material/iron = get_munition_material_by_railgun_name("Iron")
	var/list/iron_slug = aq_railgun_preview(iron.conductivity, iron.density, iron.hardness, 0)
	TEST_ASSERT_EQUAL(iron_slug["damage"], 21, "Żelazo w żelazie")
	var/datum/munition_material/silver = get_munition_material_by_railgun_name("Silver")
	var/datum/munition_material/uranium = get_munition_material_by_railgun_name("Uranium")
	// powłoka srebro, rdzeń uran: proporcje forge_slug() (przewodnictwo 75/25, gęstość i twardość 25/75)
	var/conductivity = 0.75 * silver.conductivity + 0.25 * uranium.conductivity
	var/density = 0.25 * silver.density + 0.75 * uranium.density
	var/hardness = 0.25 * silver.hardness + 0.75 * uranium.hardness
	var/list/slug = aq_railgun_preview(conductivity, density, hardness, 0)
	TEST_ASSERT_EQUAL(slug["damage"], 246, "Uran w srebrze")
	TEST_ASSERT_EQUAL(slug["penetration"], 5, "Przebicie uranu w srebrze")
	// strzał przy złym wyrównaniu szyn jest wolniejszy, a prędkość nie spada poniżej 0,1
	TEST_ASSERT(aq_railgun_velocity(conductivity, 50) < aq_railgun_velocity(conductivity, 100), "Wyrównanie szyn nie zmienia prędkości")
	TEST_ASSERT_EQUAL(aq_railgun_velocity(0, 0), 0.1, "Prędkość spadła poniżej minimum")
	TEST_ASSERT_EQUAL(aq_railgun_penetration(10, RAIL_BANANA), 0, "Bananium przebija pancerz")
	TEST_ASSERT(findtext(aq_railgun_preview_text(iron_slug), "Słabszy"), "Opis nie ostrzega przed słabym pociskiem")

/// AQUILA - rework amunicji: diament w powłoce zdziera płyty pancerza trafionej ćwiartki
/datum/unit_test/ammo_rework_armor_strip

/datum/unit_test/ammo_rework_armor_strip/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship?.use_armour_quadrants)
		return
	var/obj/item/projectile/P = allocate(/obj/item/projectile/bullet/mac_round)
	P.damage = 100
	apply_forged_munition(P, get_munition_layered(get_munition_material(/datum/material/diamond), get_munition_material(/datum/material/iron)), get_munition_quality(/datum/munition_quality))
	var/list/quad = ship.armour_quadrants[ship.projectile_quadrant_impact(P)]
	var/old_armour = quad["current_armour"]
	quad["current_armour"] = 1000
	forged_munition_overmap_hit(P, ship)
	var/stripped = 1000 - quad["current_armour"]
	quad["current_armour"] = old_armour
	ship.update_quadrants()
	TEST_ASSERT_EQUAL(stripped, round(P.damage * 0.25), "Diament w powłoce zdarł [stripped] płyt zamiast ćwierci obrażeń")

/// AQUILA - rework amunicji: grubość pancerza okrętów AI i przebicie pocisków (model jak w Nebulous)
/datum/unit_test/ammo_rework_thickness

/datum/unit_test/ammo_rework_thickness/Run()
	TEST_ASSERT_EQUAL(aq_armor_class_index(MASS_TINY), 1, "Myśliwiec nie jest w najlżejszej klasie")
	TEST_ASSERT_EQUAL(aq_armor_class_index(MASS_SMALL), 2, "Mały okręt nie jest lekki")
	TEST_ASSERT_EQUAL(aq_armor_class_index(MASS_MEDIUM), 3, "Średni okręt nie jest średni")
	TEST_ASSERT_EQUAL(aq_armor_class_index(MASS_LARGE), 4, "Duży okręt nie jest ciężki")
	TEST_ASSERT_EQUAL(aq_armor_class_index(MASS_TITAN), 5, "Tytan nie jest superciężki")
	// HE (25) przebija myśliwce i lekkie, od średnich odbija się
	TEST_ASSERT_EQUAL(aq_penetration_mult(25, 5), 1, "HE nie przebija myśliwca")
	TEST_ASSERT_EQUAL(aq_penetration_mult(25, 40), 0.1, "HE przebija średni okręt")
	// APHE (50) przelatuje myśliwiec na wylot, ciężkiego nie przebija
	TEST_ASSERT_EQUAL(aq_penetration_mult(50, 5), 0.35, "APHE nie przelatuje myśliwca na wylot")
	TEST_ASSERT_EQUAL(aq_penetration_mult(50, 40), 1, "APHE nie zadaje pełnych obrażeń średniemu okrętowi")
	TEST_ASSERT_EQUAL(aq_penetration_mult(50, 60), 0.1, "APHE przebija ciężki okręt")
	// AP (80) przelatuje lekkie na wylot, ciężkie i superciężkie przebija
	TEST_ASSERT_EQUAL(aq_penetration_mult(80, 20), 0.35, "AP nie przelatuje lekkiego okrętu na wylot")
	TEST_ASSERT_EQUAL(aq_penetration_mult(80, 40), 1, "AP nie zadaje pełnych obrażeń średniemu okrętowi")
	TEST_ASSERT_EQUAL(aq_penetration_mult(80, 80), 1, "AP nie przebija superciężkiego okrętu")

	// Pocisk AP z uranowym rdzeniem: przebicie typu + rdzeń; burtówka N dodaje swoje
	var/obj/item/projectile/bullet/mac_round/shell = allocate(/obj/item/projectile/bullet/mac_round)
	apply_forged_munition(shell, get_munition_material(/datum/material/uranium), get_munition_quality(/datum/munition_quality), get_munition_filler(/datum/munition_filler/ap))
	TEST_ASSERT_EQUAL(shell.aq_get_penetration(), 95, "Przebicie AP z uranem")
	var/obj/item/projectile/bullet/broadside/uranium/broadside = allocate(/obj/item/projectile/bullet/broadside/uranium)
	TEST_ASSERT_EQUAL(broadside.aq_get_penetration(), 65, "Przebicie burtówki N")
	var/obj/item/projectile/guided_munition/torpedo/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo)
	TEST_ASSERT(isnull(torpedo.aq_get_penetration()), "Torpeda weszła do modelu grubości pancerza")

	// Okręt gracza zostaje na pancerzu procentowym, okręt AI liczy się modelem
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship)
		return
	var/obj/item/projectile/bullet/mac_round/he_shell = allocate(/obj/item/projectile/bullet/mac_round)
	apply_forged_munition(he_shell, get_munition_material(/datum/material/iron), get_munition_quality(/datum/munition_quality), get_munition_filler(/datum/munition_filler/he))
	var/before = he_shell.damage
	var/old_ai = ship.ai_controlled
	var/old_thickness = ship.aq_armor_thickness
	ship.ai_controlled = FALSE
	ship.aq_apply_thickness_model(he_shell)
	TEST_ASSERT_EQUAL(he_shell.damage, before, "Model grubości zadziałał na okręt gracza")
	ship.ai_controlled = TRUE
	ship.aq_armor_thickness = 60
	ship.aq_apply_thickness_model(he_shell)
	ship.ai_controlled = old_ai
	ship.aq_armor_thickness = old_thickness
	TEST_ASSERT_EQUAL(he_shell.damage, round(before * 0.1, 0.1), "HE nie odbił się od ciężkiego okrętu AI")
	TEST_ASSERT_EQUAL(he_shell.armour_penetration, 100, "Po modelu grubości pancerz procentowy dalej działa")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
