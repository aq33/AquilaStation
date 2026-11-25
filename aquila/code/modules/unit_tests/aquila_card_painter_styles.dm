// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - painting an ID card in the card painter with a Munitions style made the card invisible (icon state missing in card.dmi)
/datum/unit_test/aquila_card_painter_styles

/datum/unit_test/aquila_card_painter_styles/Run()
	var/obj/machinery/pdapainter/painter = allocate(/obj/machinery/pdapainter)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)

	// Every style the machine offers must exist in the card icon
	for(var/style in painter.valid_jobs)
		if(style[1] == "-")
			continue
		var/state = get_cardstyle_by_jobname(style)
		TEST_ASSERT(icon_exists(card.icon, state), "Card style [style] sets icon state [state], missing in [card.icon]")

	// The reported case: paint a card as Master at Arms through the machine's window action
	var/mob/living/carbon/human/painter_user = allocate(/mob/living/carbon/human)
	painter.storedid = card
	card.forceMove(painter)
	var/datum/tgui/fake_ui = new(painter_user, painter, "PaintingMachine")
	fake_ui.status = UI_INTERACTIVE
	painter.ui_act("trim_card", list("selection" = JOB_NAME_MASTERATARMS), fake_ui, GLOB.default_state)
	TEST_ASSERT(card.icon_state == "maa", "Card painted as Master at Arms has icon state [card.icon_state] instead of maa")
	TEST_ASSERT(icon_exists(card.icon, card.icon_state), "Painted card has icon state [card.icon_state], missing in [card.icon]")
	qdel(fake_ui)

#undef TEST_ASSERT
