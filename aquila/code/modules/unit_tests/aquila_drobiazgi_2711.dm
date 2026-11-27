// AQUILA - testy drobiazgów 27.11: kupa rozdeptana w plamę, pot (wysiłek, szmata, sól), nieśmiertelniki i tablica pamięci,
// SOP alarmów, napis pagera nad postacią i darmowa naprawa w depocie.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Wdepnięcie w grudkę rozgniata ją w nieśliską plamę, biegunki i kopczyka felinida nie zmienia
/datum/unit_test/aquila_feces_squash

/datum/unit_test/aquila_feces_squash/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/poop_turf = get_step(start, EAST)
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, start)
	var/obj/effect/decal/cleanable/feces/stool = allocate(/obj/effect/decal/cleanable/feces, poop_turf)
	TEST_ASSERT(findtext(stool.icon_state, "floor") == 1, "Świeża kupa nie jest grudką")
	walker.forceMove(poop_turf)
	TEST_ASSERT(stool.squashed, "Wdepnięcie nie rozgniotło kupy")
	TEST_ASSERT(findtext(stool.icon_state, "diarrhea") == 1, "Rozdeptana kupa nie wygląda jak plama: [stool.icon_state]")
	TEST_ASSERT(!stool.GetComponent(/datum/component/slippery), "Rozdeptana kupa stała się śliska")

	walker.forceMove(start)
	var/obj/effect/decal/cleanable/feces/felinid/purple = allocate(/obj/effect/decal/cleanable/feces/felinid, get_step(poop_turf, EAST))
	walker.forceMove(get_turf(purple))
	TEST_ASSERT_EQUAL(purple.icon_state, "felinid", "Rozdeptanie zmieniło fioletowy kopczyk")

/// Sprint poci, pot zabiera wodę, szmata go zbiera, a podgrzany pot zostawia sól
/datum/unit_test/aquila_sweat

/datum/unit_test/aquila_sweat/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/hydration_before = runner.hydration
	runner.exert(150)
	TEST_ASSERT(runner.sweat >= 5, "Pełny sprint nie spocił postaci: [runner.sweat]")
	TEST_ASSERT(runner.hydration < hydration_before, "Pot nie zabrał nawodnienia")
	runner.exert(1000)
	TEST_ASSERT(runner.sweat <= 10, "Pot przekroczył limit: [runner.sweat]")

	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/reagent_containers/glass/rag/rag = allocate(/obj/item/reagent_containers/glass/rag)
	rag.sweat_wipe_time = 0
	helper.put_in_hands(rag)
	var/sweat_before = runner.sweat
	rag.afterattack(runner, helper, TRUE)
	TEST_ASSERT(rag.reagents.has_reagent(/datum/reagent/sweat, 5), "Szmata nie nasiąkła potem")
	TEST_ASSERT_EQUAL(runner.sweat, sweat_before - 5, "Ocieranie nie zabrało potu ze skóry")

	SEND_SIGNAL(runner, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	TEST_ASSERT_EQUAL(runner.sweat, 0, "Mycie nie zmyło potu")

	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/sweat, 10)
	beaker.reagents.set_temperature(400)
	beaker.reagents.handle_reactions()
	TEST_ASSERT(beaker.reagents.has_reagent(/datum/reagent/consumable/sodiumchloride, 2), "Podgrzany pot nie zostawił soli")

/// Nieśmiertelnik ze zwłok (okno przeszukiwania) trafia na tablicę pamięci, a z identyfikatora da się go zdjąć tylko raz
/datum/unit_test/aquila_dogtags

/datum/unit_test/aquila_dogtags/Run()
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	corpse.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(corpse), ITEM_SLOT_ICLOTHING)
	var/obj/item/card/id/id_card = new(corpse)
	id_card.registered_name = "Jan Testowy"
	id_card.assignment = "Inżynier"
	TEST_ASSERT(corpse.equip_to_slot_or_del(id_card, ITEM_SLOT_ID), "Nie udało się założyć identyfikatora")

	var/datum/strippable_item/mob_item_slot/needs_jumpsuit/id/id_slot = GLOB.strippable_human_items[STRIPPABLE_ITEM_ID]
	TEST_ASSERT(isnull(id_slot.get_alternate_action(corpse, medic)), "Z żywego da się zdjąć nieśmiertelnik")
	corpse.death()
	TEST_ASSERT_EQUAL(id_slot.get_alternate_action(corpse, medic), "take_dogtag", "Przy zwłokach brak akcji nieśmiertelnika")

	var/old_time = id_slot.dogtag_time
	id_slot.dogtag_time = 0
	id_slot.alternate_action(corpse, medic)
	id_slot.dogtag_time = old_time
	var/obj/item/dogtag/tag = medic.is_holding_item_of_type(/obj/item/dogtag)
	TEST_ASSERT(tag, "Medyk nie dostał nieśmiertelnika")
	TEST_ASSERT_EQUAL(tag.fallen_name, "Jan Testowy", "Na nieśmiertelniku jest złe imię")
	TEST_ASSERT(id_card.dogtag_taken, "Identyfikator nie zapamiętał zdjęcia nieśmiertelnika")
	TEST_ASSERT(isnull(id_slot.get_alternate_action(corpse, medic)), "Nieśmiertelnik da się zdjąć drugi raz")

	var/obj/structure/memorial_board/board = allocate(/obj/structure/memorial_board, get_step(medic, NORTH))
	GLOB.memorial_fallen -= "Jan Testowy"
	board.attackby(tag, medic)
	TEST_ASSERT(GLOB.memorial_fallen["Jan Testowy"], "Tablica nie zapisała poległego")
	TEST_ASSERT(QDELETED(tag), "Nieśmiertelnik nie został na tablicy")
	TEST_ASSERT(findtext(jointext(board.memorial_lines(), " "), "Jan Testowy"), "Oględziny tablicy nie pokazują poległego")
	GLOB.memorial_fallen -= "Jan Testowy"

/// SOP: każdy stan ma ściągę, czat dostaje ją po zmianie stanu, PDA ma program, a pager w kieszeni skraca wiadomość do napisu
/datum/unit_test/aquila_alert_sop

/datum/unit_test/aquila_alert_sop/Run()
	for(var/level in list(SEC_LEVEL_GREEN, SEC_LEVEL_BLUE, SEC_LEVEL_RED, SEC_LEVEL_ZEBRA, SEC_LEVEL_DELTA))
		var/list/entry = alert_sop_entry(level)
		TEST_ASSERT(entry && length(entry["rules"]), "Stan [level] nie ma ściągi SOP")
		TEST_ASSERT(findtext(alert_sop_chat_text(level), entry["name"]), "Blok SOP w czacie nie nazywa stanu [level]")
	var/obj/item/modular_computer/tablet/pda/pda = allocate(/obj/item/modular_computer/tablet/pda)
	var/obj/item/computer_hardware/hard_drive/hdd = pda.all_components[MC_HDD]
	TEST_ASSERT(hdd?.find_file_by_name("sop"), "Nowe PDA nie ma programu SOP")

	var/long_text = "Wszyscy natychmiast do hangaru, Sabre startuje za dwie minuty i nikt nie czeka na spóźnionych"
	var/overhead = squad_pager_overhead_text("Sierżant", long_text)
	TEST_ASSERT(findtext(overhead, "Sierżant: Wszyscy") == 1, "Napis pagera nie zaczyna się od nadawcy: [overhead]")
	TEST_ASSERT(length_char(overhead) < length_char(long_text), "Napis pagera nie został skrócony")

/// Sojuszniczy depot naprawia okręt gracza, a przy wrogim właścicielu przerywa
/datum/unit_test/aquila_depot_repair

/datum/unit_test/aquila_depot_repair/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship?.current_system, "Brak głównego okrętu w układzie")
	var/datum/star_system/S = ship.current_system
	var/old_owner = S.owner
	var/old_alignment = S.alignment
	var/had_depot = (HEX_FAC_DEPOT in S.war_facilities)
	var/old_integrity = ship.obj_integrity
	var/list/old_fleets = S.fleets
	S.fleets = list()
	S.owner = ship.faction
	S.alignment = ship.faction
	if(!had_depot)
		LAZYADD(S.war_facilities, HEX_FAC_DEPOT)

	ship.obj_integrity = ship.max_integrity * 0.5
	ship.try_start_depot_repair(S)
	TEST_ASSERT_EQUAL(ship.depot_repair_system, S, "Depot nie przyjął okrętu do naprawy")
	ship.depot_repair_tick()
	TEST_ASSERT(ship.obj_integrity > ship.max_integrity * 0.5, "Depot nie naprawił kadłuba")

	S.owner = "syndicate"
	ship.depot_repair_tick()
	TEST_ASSERT(isnull(ship.depot_repair_system), "Wrogi depot dalej naprawia")

	ship.depot_repair_system = null
	ship.obj_integrity = old_integrity
	S.fleets = old_fleets
	S.owner = old_owner
	S.alignment = old_alignment
	if(!had_depot)
		LAZYREMOVE(S.war_facilities, HEX_FAC_DEPOT)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
