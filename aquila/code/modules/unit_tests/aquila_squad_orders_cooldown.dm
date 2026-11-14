// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Odstęp rozkazów liczy się na drużynę: rozkaz dla Alpha blokuje kolejny dla Alpha (także od innego nadawcy), ale nie dla Bravo
/datum/unit_test/aquila_squad_orders_cooldown

/datum/unit_test/aquila_squad_orders_cooldown/Run()
	var/datum/squad/alpha = GLOB.squad_manager.get_squad("Alpha")
	var/datum/squad/bravo = GLOB.squad_manager.get_squad("Bravo")
	TEST_ASSERT(alpha && bravo, "Brak drużyny Alpha albo Bravo")
	var/old_alpha = alpha.aq_next_order
	var/old_bravo = bravo.aq_next_order
	alpha.aq_next_order = 0
	bravo.aq_next_order = 0
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/other_officer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)

	TEST_ASSERT(alpha.aq_issue_order(officer, "Naprzód", from_console = TRUE), "Pierwszy rozkaz dla Alpha nie przeszedł")
	TEST_ASSERT(alpha.aq_order_cooldown_left() > 0, "Po rozkazie Alpha nie ma odstępu")
	TEST_ASSERT(!alpha.aq_can_issue_order(officer), "Drugi rozkaz dla Alpha od tego samego nadawcy nie jest blokowany")
	TEST_ASSERT(!alpha.aq_issue_order(other_officer, "Stać"), "Rozkaz dla Alpha od innego nadawcy ominął odstęp drużyny")
	TEST_ASSERT(bravo.aq_can_issue_order(officer), "Rozkaz dla Alpha zablokował rozkazy dla Bravo")
	TEST_ASSERT(bravo.aq_issue_order(officer, "Osłaniać", from_console = TRUE), "Rozkaz dla Bravo od tego samego nadawcy nie przeszedł")
	var/list/alpha_data = alpha.aq_squad_data(include_members = FALSE)
	TEST_ASSERT(alpha_data["order_cooldown"] > 0, "Dane drużyny dla okien nie pokazują odstępu rozkazu")

	alpha.aq_next_order = old_alpha
	bravo.aq_next_order = old_bravo

/// Pager z autolatu: bez drużyny użycie w ręce nie rzuca runtime i nic nie przypisuje; projekt jest w autolacie
/datum/unit_test/aquila_squad_pager_printed

/datum/unit_test/aquila_squad_pager_printed/Run()
	var/datum/design/design = SSresearch.techweb_design_by_id("squad_pager")
	TEST_ASSERT(design?.build_path == /obj/item/squad_pager, "Brak projektu pagera drużyny")
	TEST_ASSERT(design.build_type & AUTOLATHE, "Projekt pagera drużyny nie jest dla autolatu")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!user.squad, "Świeży człowiek ma drużynę")
	var/obj/item/squad_pager/pager = allocate(/obj/item/squad_pager, run_loc_floor_bottom_left, null)
	TEST_ASSERT(!pager.squad && !pager.squad_channel, "Wydrukowany pager ma drużynę albo kanał")
	pager.attack_self(user)
	TEST_ASSERT(!pager.squad, "Użycie pagera bez drużyny przypisało drużynę")

	// Konsola XO drukuje pager przypisany do drużyny, z odstępem jak przy smyczy
	var/datum/squad/squad = GLOB.squad_manager.squads[1]
	var/obj/machinery/computer/squad_manager/console = allocate(/obj/machinery/computer/squad_manager, run_loc_floor_top_right)
	var/list/state = list()
	TEST_ASSERT(aq_squad_console_act("aq_print_pager", list("squad_id" = REF(squad)), user, console, null, state), "Konsola nie wydrukowała pagera")
	var/obj/item/squad_pager/printed = locate() in get_turf(console)
	TEST_ASSERT(printed?.squad == squad, "Wydrukowany pager nie jest przypisany do drużyny [squad]")
	TEST_ASSERT(!aq_squad_console_act("aq_print_pager", list("squad_id" = REF(squad)), user, console, null, state), "Drugi pager wydrukował się bez odstępu")
	qdel(printed)

/// Szafka XO (także wersja z NSV bez ..()) ma globalny pager drużyn, dokładnie jeden
/datum/unit_test/aquila_squad_pager_xo_closet

/datum/unit_test/aquila_squad_pager_xo_closet/Run()
	for(var/closet_type in list(/obj/structure/closet/secure_closet/hop, /obj/structure/closet/secure_closet/hop/solgov))
		var/obj/structure/closet/closet = allocate(closet_type, run_loc_floor_bottom_left)
		var/pagers = 0
		for(var/obj/item/squad_pager/all_channels/pager in closet)
			pagers++
		TEST_ASSERT(pagers == 1, "[closet_type] ma [pagers] globalnych pagerów drużyn zamiast 1")

#undef TEST_ASSERT
