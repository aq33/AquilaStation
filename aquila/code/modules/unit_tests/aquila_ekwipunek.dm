// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Czapka na hełmie hardsuitu: zakładanie, druga czapka, nakładka, zdejmowanie, czapka przez kombinezon
/datum/unit_test/aquila_hardsuit_hat

/datum/unit_test/aquila_hardsuit_hat/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/suit/space/hardsuit/engine/suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine)
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet = suit.helmet
	TEST_ASSERT(helmet, "Hardsuit nie ma hełmu")
	var/obj/item/clothing/head/beret/hat = allocate(/obj/item/clothing/head/beret)
	var/obj/item/clothing/head/that/second_hat = allocate(/obj/item/clothing/head/that)

	// czapka kliknięta w kombinezon trafia na schowany hełm
	wearer.put_in_hands(hat)
	suit.attackby(hat, wearer)
	TEST_ASSERT(helmet.attached_hat == hat && hat.loc == helmet, "Czapka kliknięta w kombinezon nie trafiła na hełm")
	var/overlays_with_hat = length(helmet.worn_overlays(null, FALSE))
	TEST_ASSERT(overlays_with_hat >= 1, "Hełm z czapką nie dodaje nakładki")

	// druga czapka się nie mieści
	wearer.put_in_hands(second_hat)
	helmet.attackby(second_hat, wearer)
	TEST_ASSERT(helmet.attached_hat == hat && second_hat.loc != helmet, "Druga czapka weszła na hełm z czapką")

	// hełm na hełmie nie przechodzi
	var/obj/item/clothing/head/helmet/space/eva = allocate(/obj/item/clothing/head/helmet/space)
	TEST_ASSERT(!helmet.can_attach_hat(eva), "Hełm kosmiczny dał się założyć jako czapka")

	// zdejmowanie
	TEST_ASSERT(helmet.detach_hat(wearer) == hat, "Zdjęcie czapki nie zwróciło czapki")
	TEST_ASSERT(!helmet.attached_hat && hat.loc != helmet, "Czapka została w hełmie po zdjęciu")
	TEST_ASSERT(length(helmet.worn_overlays(null, FALSE)) < overlays_with_hat, "Nakładka czapki została po zdjęciu")

/// Kupa: felinid zostawia fioletowy kopczyk, biegunka zmienia grudki w rozbryzg (a fioletowy kopczyk zostaje)
/datum/unit_test/aquila_feces_look

/datum/unit_test/aquila_feces_look/Run()
	var/mob/living/carbon/human/cat = allocate(/mob/living/carbon/human)
	cat.set_species(/datum/species/human/felinid)
	cat.set_defecation(DEFECATION_SHIT_YOURSELF)
	cat.finish_defecate_here(FALSE)
	var/obj/effect/decal/cleanable/feces/felinid/purple = locate() in get_turf(cat)
	TEST_ASSERT(purple && purple.icon_state == "felinid", "Felinid nie zostawił fioletowego kopczyka")
	purple.make_diarrhea()
	TEST_ASSERT(purple.icon_state == "felinid", "Biegunka zmieniła fioletowy kopczyk")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	TEST_ASSERT(human.feces_type() == /obj/effect/decal/cleanable/feces, "Człowiek ma inny typ kupy niż zwykły")
	var/obj/effect/decal/cleanable/feces/stool = allocate(/obj/effect/decal/cleanable/feces, run_loc_floor_top_right)
	TEST_ASSERT(findtext(stool.icon_state, "floor") == 1, "Zwykła kupa nie jest grudkami: [stool.icon_state]")
	stool.make_diarrhea()
	TEST_ASSERT(findtext(stool.icon_state, "diarrhea") == 1, "Biegunka nie zmieniła wyglądu: [stool.icon_state]")

	// typ 7 w skali bristolskiej (olej rycynowy) zostawia rozbryzg
	var/turf/runny_spot = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/carbon/human/runny = allocate(/mob/living/carbon/human, runny_spot)
	runny.reagents.add_reagent(/datum/reagent/consumable/castor_oil, 5)
	runny.set_defecation(DEFECATION_SHIT_YOURSELF)
	runny.finish_defecate_here(FALSE)
	var/obj/effect/decal/cleanable/feces/runny_stool = locate() in runny_spot
	TEST_ASSERT(runny_stool?.stool_type == 7, "Olej rycynowy nie dał typu 7 (typ [runny_stool?.stool_type])")
	TEST_ASSERT(findtext(runny_stool.icon_state, "diarrhea") == 1, "Typ 7 nie zostawił rozbryzgu: [runny_stool.icon_state]")

	// biegunka na polu z leżącą już kupą: nowa zlewa się ze starą, więc to stara ma pokazać rozbryzg
	var/turf/dirty_spot = locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/effect/decal/cleanable/feces/old_stool = allocate(/obj/effect/decal/cleanable/feces, dirty_spot)
	var/mob/living/carbon/human/runny2 = allocate(/mob/living/carbon/human, dirty_spot)
	runny2.reagents.add_reagent(/datum/reagent/consumable/castor_oil, 5)
	runny2.set_defecation(DEFECATION_SHIT_YOURSELF)
	runny2.finish_defecate_here(FALSE)
	var/stools_here = 0
	for(var/obj/effect/decal/cleanable/feces/F in dirty_spot)
		stools_here++
	TEST_ASSERT(stools_here == 1, "Kupa na polu z kupą się nie zlała ([stools_here] kupy)")
	TEST_ASSERT(old_stool.stool_type == 7 && findtext(old_stool.icon_state, "diarrhea") == 1, "Biegunka na leżącej kupie zostawiła grudki: [old_stool.icon_state], typ [old_stool.stool_type]")

/// Okno kafelka (Alt-klik) na hardsuit: bez czapki otwiera się jak zwykle, z czapką Alt-klik ją zdejmuje
/datum/unit_test/aquila_hardsuit_hat_loot_panel

/datum/unit_test/aquila_hardsuit_hat_loot_panel/Run()
	var/obj/item/clothing/suit/space/hardsuit/engine/suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine)
	TEST_ASSERT(suit.opens_loot_panel() && suit.helmet.opens_loot_panel(), "Hardsuit bez czapki nie otwiera okna kafelka")
	var/obj/item/clothing/head/beret/hat = allocate(/obj/item/clothing/head/beret)
	suit.helmet.attach_hat(hat)
	TEST_ASSERT(!suit.opens_loot_panel() && !suit.helmet.opens_loot_panel(), "Hardsuit z czapką otwiera okno kafelka zamiast zdjąć czapkę")

/// Barykady kierunkowe z zachowaniem z TGMC: pociski od frontu, drut, wzmacnianie podstawy, worki, składana metalowa, receptury
/datum/unit_test/aquila_tgmc_barricades

/datum/unit_test/aquila_tgmc_barricades/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/turf/spot = locate(base.x + 1, base.y + 1, base.z)
	var/turf/front = get_step(spot, NORTH)
	var/turf/behind = get_step(spot, SOUTH)
	var/obj/structure/peacekeeper_barricade/metal/cade = allocate(/obj/structure/peacekeeper_barricade/metal, spot)
	cade.setDir(NORTH)

	// pociski: od frontu z szansą, zza barykady zawsze, strzelec tuż przy barykadzie strzela nad nią
	var/obj/item/projectile/bullet = allocate(/obj/item/projectile, front)
	cade.proj_pass_rate = 0
	TEST_ASSERT(!cade.CanAllowThrough(bullet, front), "Pocisk od frontu przeleciał przy szansie 0%")
	cade.proj_pass_rate = 100
	var/obj/item/projectile/lucky = allocate(/obj/item/projectile, front) // wynik jest zapamiętany na pocisk, więc nowy pocisk
	TEST_ASSERT(cade.CanAllowThrough(lucky, front), "Pocisk od frontu nie przeleciał przy szansie 100%")
	cade.proj_pass_rate = 0
	TEST_ASSERT(cade.CanAllowThrough(bullet, behind), "Pocisk zza barykady został zatrzymany")
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, front)
	bullet.firer = shooter
	TEST_ASSERT(cade.CanAllowThrough(bullet, front), "Strzelec tuż przed barykadą nie strzela nad nią")
	bullet.firer = null
	// jedno losowanie na pocisk: kolejne sprawdzenia tego samego pocisku dają ten sam wynik
	var/obj/item/projectile/rolled = allocate(/obj/item/projectile, front)
	cade.proj_pass_rate = 50
	var/first_roll = cade.CanAllowThrough(rolled, front)
	for(var/i in 1 to 20)
		TEST_ASSERT(cade.CanAllowThrough(rolled, front) == first_roll, "Przelot tego samego pocisku losowany od nowa")
	cade.proj_pass_rate = 0

	// drut kolczasty: po rozłożeniu nie da się przeskoczyć
	var/mob/living/carbon/human/builder = allocate(/mob/living/carbon/human, behind)
	var/obj/item/stack/barbed_wire/wire = allocate(/obj/item/stack/barbed_wire/five, behind)
	builder.put_in_hands(wire)
	cade.attackby(wire, builder)
	TEST_ASSERT(cade.is_wired && !cade.climbable, "Barykada z drutem nadal pozwala przeskoczyć")

	// podstawa: poniżej 30% wzmacniają ją arkusze
	cade.obj_integrity = 10
	var/obj/item/stack/sheet/iron/five/sheets = allocate(/obj/item/stack/sheet/iron/five, behind)
	builder.put_in_hands(sheets)
	cade.attackby(sheets, builder)
	TEST_ASSERT(cade.obj_integrity >= cade.max_integrity * 0.3, "Arkusze nie wzmocniły podstawy (wytrzymałość [cade.obj_integrity])")
	TEST_ASSERT(sheets.get_amount() == 3, "Wzmocnienie podstawy zużyło [5 - sheets.get_amount()] arkuszy zamiast 2")

	// worki z piaskiem: naprawa workiem
	var/turf/sand_spot = locate(base.x + 3, base.y + 1, base.z)
	var/obj/structure/peacekeeper_barricade/metal/sandbags/bags_cade = allocate(/obj/structure/peacekeeper_barricade/metal/sandbags, sand_spot)
	bags_cade.obj_integrity = bags_cade.max_integrity / 2
	var/before = bags_cade.obj_integrity
	var/obj/item/stack/sheet/mineral/sandbags/bags = allocate(/obj/item/stack/sheet/mineral/sandbags, sand_spot)
	builder.forceMove(sand_spot)
	builder.put_in_hands(bags)
	bags_cade.attackby(bags, builder)
	TEST_ASSERT(bags_cade.obj_integrity > before, "Worek nie naprawił barykady z worków")

	// składana metalowa: stoi po zbudowaniu, składa się ręką
	var/turf/fold_spot = locate(base.x + 1, base.y + 3, base.z)
	var/obj/structure/peacekeeper_barricade/metal/plasteel/folding_metal/folding = allocate(/obj/structure/peacekeeper_barricade/metal/plasteel/folding_metal, fold_spot)
	TEST_ASSERT(folding.density && !folding.closed, "Składana metalowa barykada nie stoi po zbudowaniu")
	builder.forceMove(fold_spot)
	builder.drop_all_held_items()
	folding.attack_hand(builder)
	TEST_ASSERT(folding.closed && !folding.density, "Składana metalowa barykada nie złożyła się")

	// receptury
	var/found_sandbags = FALSE
	for(var/datum/stack_recipe/recipe in GLOB.sandbag_recipes)
		if(recipe.result_type == /obj/structure/peacekeeper_barricade/metal/sandbags)
			found_sandbags = TRUE
	TEST_ASSERT(found_sandbags, "Brak receptury kierunkowej barykady z worków")
	var/found_folding = FALSE
	for(var/datum/stack_recipe/recipe in GLOB.metal_recipes)
		if(recipe.result_type == /obj/structure/peacekeeper_barricade/metal/plasteel/folding_metal)
			found_folding = TRUE
	TEST_ASSERT(found_folding, "Brak receptury składanej metalowej barykady")

/// Testowa barykada, której wspinanie czyści trasę boardera (jak walka albo odwrót w trakcie do_mob przy wspinaniu)
/obj/structure/peacekeeper_barricade/metal/aquila_test_path_clear
	var/datum/component/knpc/clears_path_of

/obj/structure/peacekeeper_barricade/metal/aquila_test_path_clear/climb_structure(mob/living/user)
	clears_path_of?.path = list()

/// Abordażyści AI a barykady: drut zatrzymuje ich trasę i wspinanie, a trasa wyczyszczona przy wspinaniu nie daje runtime'u
/datum/unit_test/aquila_knpc_barricades

/datum/unit_test/aquila_knpc_barricades/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/turf/start = locate(base.x + 1, base.y + 1, base.z)
	var/turf/cade_turf = locate(base.x + 2, base.y + 1, base.z)
	var/turf/beyond = locate(base.x + 3, base.y + 1, base.z)
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, start)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)

	// regresja: trasa znika w trakcie wspinania (next_path_step czytało path[1] z pustej listy)
	var/obj/structure/peacekeeper_barricade/metal/aquila_test_path_clear/clearing = allocate(/obj/structure/peacekeeper_barricade/metal/aquila_test_path_clear, cade_turf)
	clearing.setDir(WEST)
	clearing.clears_path_of = ai
	ai.path = list(cade_turf, beyond)
	ai.next_move = 0
	ai.tries = 0
	TEST_ASSERT(ai.next_path_step() == FALSE, "Boarder szedł dalej po wyczyszczeniu trasy przy wspinaniu")
	qdel(clearing)

	// drut: boarder nie wspina się na barykadę i nie planuje przez nią trasy
	var/obj/structure/peacekeeper_barricade/metal/wired = allocate(/obj/structure/peacekeeper_barricade/metal, cade_turf)
	wired.setDir(WEST)
	TEST_ASSERT(wired.CanAStarPass(null, WEST, boarder), "Boarder bez drutu nie planuje trasy przez barykadę (wspina się na nie)")
	wired.is_wired = TRUE
	wired.climbable = FALSE
	TEST_ASSERT(!wired.CanAStarPass(null, WEST, boarder), "Boarder planuje trasę przez barykadę z drutem")
	TEST_ASSERT(wired.CanAStarPass(null, EAST, boarder), "Barykada z drutem blokuje trasę od tyłu")
	ai.path = list(cade_turf, beyond)
	ai.next_move = 0
	ai.tries = 0
	ai.next_path_step()
	TEST_ASSERT(get_turf(boarder) == start, "Boarder przeszedł przez barykadę z drutem")

#undef TEST_ASSERT
